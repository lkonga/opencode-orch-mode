#!/bin/bash
# Universal sudo wrapper script for local script execution with automated password handling
# Integrates with trunner for protected execution of long-running operations
#
# Usage:
#   ./sudo-runner.sh [--trunner] <script-path> [args...]
#   ./sudo-runner.sh [--trunner] "<inline-command>"
#
# Examples:
#   ./sudo-runner.sh ./scripts/setup-worktree.sh worktree-01
#   ./sudo-runner.sh --trunner ./scripts/deploy-worktree.sh prod-01
#   ./sudo-runner.sh "systemctl restart nginx"
#   ./sudo-runner.sh --trunner "apt-get update && apt-get upgrade -y"

set -euo pipefail

# Configuration
SUDO_PASSWORD='$$$123123'
# Save original working directory BEFORE any cd operations
ORIGINAL_PWD="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRUNNER_SCRIPT="${HOME}/codes/llm-rules/scripts/tmux-runner/trunner.sh"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_usage() {
    cat << EOF
${BLUE}Local Sudo Runner${NC} - Run scripts with automated sudo authentication

${GREEN}Usage:${NC}
    $0 [OPTIONS] <script-path> [args...]
    $0 [OPTIONS] "<inline-command>"

${GREEN}Options:${NC}
    --trunner           Execute command in tmux-protected session
    --help, -h          Display this help message

${GREEN}Examples:${NC}
    # Run script with sudo
    $0 ./scripts/setup-worktree.sh worktree-01

    # Run inline command with sudo
    $0 "systemctl restart php8.2-fpm"

    # Protected execution with trunner
    $0 --trunner ./scripts/long-running-deploy.sh

    # Inline command with trunner
    $0 --trunner "apt-get update && apt-get upgrade -y"

${GREEN}Related Skills:${NC}
    \$TmuxProtectedExecution - Tmux session management
    \$VPSSudoPassword        - Remote sudo operations
    \$WorktreeOrchestration  - Worktree lifecycle

${GREEN}Logs:${NC}
    When using --trunner, output is logged to:
    /tmp/test_suite_output_tmux-runner-*.log

${GREEN}Monitoring:${NC}
    # List active trunner sessions
    ${TRUNNER_SCRIPT} --list

    # View live logs
    tail -f /tmp/test_suite_output_tmux-runner-*.log

    # Kill specific session
    ${TRUNNER_SCRIPT} --kill SESSION_ID
EOF
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Parse arguments
USE_TRUNNER=false
DEBUG_MODE=false
COMMAND_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --trunner)
            USE_TRUNNER=true
            shift
            ;;
        --debug)
            DEBUG_MODE=true
            shift
            ;;
        --help|-h)
            print_usage
            exit 0
            ;;
        *)
            COMMAND_ARGS+=("$1")
            shift
            ;;
    esac
done

# Validate arguments
if [[ ${#COMMAND_ARGS[@]} -eq 0 ]]; then
    log_error "No command provided"
    print_usage
    exit 1
fi

# Build the command to execute
if [[ -f "${COMMAND_ARGS[0]}" ]]; then
    # Script path provided - use as-is to preserve symlinks and relative paths
    # Don't use realpath as it resolves symlinks to their actual location
    # which breaks the project directory detection
    SCRIPT_PATH="${COMMAND_ARGS[0]}"

    if [[ ! -x "${SCRIPT_PATH}" ]]; then
        log_warning "Script is not executable, attempting to make it executable..."
        echo "${SUDO_PASSWORD}" | sudo -S chmod +x "${SCRIPT_PATH}" 2>/dev/null || {
            log_error "Failed to make script executable: ${SCRIPT_PATH}"
            exit 1
        }
    fi

    # Build command with proper quoting for arguments with spaces
    SUDO_COMMAND="${SCRIPT_PATH}"
    for ((i=1; i<${#COMMAND_ARGS[@]}; i++)); do
        # Quote each argument to preserve spaces
        SUDO_COMMAND="${SUDO_COMMAND} \"${COMMAND_ARGS[i]}\""
    done
else
    # Inline command or script name
    SUDO_COMMAND="${COMMAND_ARGS[*]}"
fi

log_info "Preparing sudo execution..."

# Debug mode - show directory resolution without executing
if [[ "${DEBUG_MODE}" == "true" ]]; then
    echo ""
    echo -e "${BLUE}=== SUDO-RUNNER DEBUG MODE ===${NC}"
    echo -e "${YELLOW}Current directory (pwd):${NC} $(pwd)"
    echo -e "${YELLOW}SCRIPT_DIR (sudo-runner.sh location):${NC} ${SCRIPT_DIR}"
    echo -e "${YELLOW}Command to execute:${NC} ${SUDO_COMMAND}"
    echo -e "${YELLOW}Use trunner:${NC} ${USE_TRUNNER}"
    if [[ "${USE_TRUNNER}" == "true" ]]; then
        echo -e "${YELLOW}ORIGINAL_PWD (will pass to trunner):${NC} $(pwd)"
        echo -e "${YELLOW}Trunner script:${NC} ${TRUNNER_SCRIPT}"
    fi
    echo -e "${BLUE}==============================${NC}"
    echo ""
    exit 0
fi

# Execute with or without trunner
if [[ "${USE_TRUNNER}" == "true" ]]; then
    # Check if trunner exists
    if [[ ! -f "${TRUNNER_SCRIPT}" ]]; then
        log_error "Trunner script not found: ${TRUNNER_SCRIPT}"
        log_error "Please ensure \$TmuxProtectedExecution skill is available"
        exit 1
    fi

    log_info "Executing in tmux-protected session..."
    log_info "Command: ${SUDO_COMMAND}"

    # Create a temporary wrapper script for trunner
    # Note: Don't use trap to delete - trunner needs the file to exist
    TEMP_WRAPPER=$(mktemp /tmp/sudo-runner-wrapper-XXXXXX.sh)

    # Create wrapper - using unquoted heredoc delimiter for variable expansion
    # Variables expand NOW at wrapper creation time, not in sudo context
    cat > "${TEMP_WRAPPER}" << WRAPPER_EOF
#!/bin/bash
set -euo pipefail

# Change to original working directory before executing command
# This is necessary because sudo bash -c does not preserve tmux's -c directory
cd "${ORIGINAL_PWD}" || exit 1

# Preserve SSH agent socket for key authentication
export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-}"
export SSH_AGENT_PID="${SSH_AGENT_PID:-}"
# Preserve debug flags
export DEBUG_ARGS="${DEBUG_ARGS:-false}"

# Execute the sudo command with SSH environment preserved
echo '${SUDO_PASSWORD}' | sudo -S -E bash -c '${SUDO_COMMAND}'
WRAPPER_EOF

    chmod +x "${TEMP_WRAPPER}"

    # Debug: Show what will be passed to trunner
    log_info "Passing to trunner: -d '${ORIGINAL_PWD}'"

    # Execute via trunner with working directory preserved
    # Pass -d flag to trunner to set tmux session working directory
    SESSION_ID=$("${TRUNNER_SCRIPT}" -d "${ORIGINAL_PWD}" "${TEMP_WRAPPER}" 2>&1 | grep -oP 'tmux-runner-\d+-\d+' | head -1)

    # Clean up wrapper after brief delay (trunner has copied it)
    (sleep 2 && rm -f "${TEMP_WRAPPER}") &

    if [[ -n "${SESSION_ID}" ]]; then
        log_success "Tmux session created: ${SESSION_ID}"
        log_info "Monitor with: tail -f /tmp/test_suite_output_${SESSION_ID}.log"
        log_info "Kill with: ${TRUNNER_SCRIPT} --kill ${SESSION_ID}"
    else
        log_warning "Could not extract session ID, check trunner output"
    fi

else
    # Direct execution with sudo
    log_info "Executing with sudo..."
    log_info "Command: ${SUDO_COMMAND}"

    # Execute and capture exit code
    set +e
    echo "${SUDO_PASSWORD}" | sudo -S bash -c "${SUDO_COMMAND}"
    EXIT_CODE=$?
    set -e

    if [[ ${EXIT_CODE} -eq 0 ]]; then
        log_success "Command completed successfully"
    else
        log_error "Command failed with exit code: ${EXIT_CODE}"
        exit ${EXIT_CODE}
    fi
fi

exit 0
