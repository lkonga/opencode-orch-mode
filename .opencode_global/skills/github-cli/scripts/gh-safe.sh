#!/bin/bash

# ===============================================================================
# GitHub CLI Safe Wrapper - Portable Skill Version
# ===============================================================================
#
# OVERARCHING GOALS:
# 1. Prevent LLM agents from accidentally modifying upstream repositories
# 2. Block interactive commands that can hang automated processes
# 3. Allow safe read operations on any repository
# 4. Provide clear guidance for LLM agents when operations are blocked
# 5. Maintain full functionality for human operators with override options
# 6. Work as a portable skill without requiring system-wide installation
#
# PROTECTION STRATEGY:
# - Microsoft repositories: Write operations blocked (critical protection)
# - Interactive commands: Blocked to prevent LLM hanging
# - Read operations: Allowed on any repository
# - User repositories: Full access allowed
# - Human overrides: Available via environment variables
#
# USAGE:
#   Normal use: ./gh-safe.sh gh <command> (same as original GitHub CLI)
#   Override upstream: ALLOW_UPSTREAM=true ./gh-safe.sh gh <command> (human only)
#   Override interactive: ALLOW_INTERACTIVE=true ./gh-safe.sh gh <command> (human only)
#
# ===============================================================================

set -euo pipefail

# ===============================================================================
# COLOR CONSTANTS - For consistent error and info messaging
# ===============================================================================
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_RESET='\033[0m'

# ===============================================================================
# CONFIGURATION - Protection scope and original binary location
# ===============================================================================
readonly PATH_TO_ORIGINAL_GH="${ORIGINAL_GH:-gh}"
readonly ALLOWED_GITHUB_USERS="${ALLOWED_USERS:-lkonga,yzgyzinc}"
readonly ALLOWED_GITHUB_ORGS="${ALLOWED_ORGS:-lkonga,yzgyzinc}"
# Microsoft repositories requiring write protection (critical for upstream safety)
readonly PROTECTED_MICROSOFT_REPOS="${MICROSOFT_REPOS:-microsoft/vscode,microsoft/vscode-copilot,microsoft/vscode-copilot-release,microsoft/TypeScript,microsoft/vscode-extensions}"

# ===============================================================================
# SKILL-SPECIFIC MESSAGING FUNCTIONS - Enhanced with progressive disclosure hints
# ===============================================================================

# Display error message with consistent formatting and skill guidance
# Args: $1 - Error message to display
print_error_message() {
    echo -e "${COLOR_RED}❌ ERROR: $1${COLOR_RESET}" >&2
}

# Display info message with consistent formatting
# Args: $1 - Information message to display
print_info_message() {
    echo -e "${COLOR_BLUE}ℹ️  $1${COLOR_RESET}" >&2
}

# Print skill hint for progressive disclosure
# Args: $1 - Disclosure level (D0-D5)
#       $2 - Hint message
print_skill_hint() {
    local depth="$1"
    local hint="$2"
    echo -e "${COLOR_YELLOW}💡 SKILL HINT ($depth): $hint${COLOR_RESET}" >&2
}

# ===============================================================================
# INTERACTIVE COMMAND DETECTION - Prevent LLM agent hanging
# ===============================================================================

# Determine if a GitHub CLI command requires user interaction
# Interactive commands can hang LLM agents indefinitely
# Args: $1 - Command name, $2+ - Command arguments
# Returns: 0 if interactive, 1 if non-interactive
is_github_command_interactive() {
    local cmd="$1"
    case "$cmd" in
        "extension"|"ext")
            [[ "${2:-}" == "browse" ]] && return 0
            ;;
        "browse")
            # Check if --no-browser flag is present
            if [[ ! " ${*:2} " =~ " --no-browser " ]] && [[ ! " ${*:2} " =~ " -n " ]]; then
                return 0
            fi
            ;;
        "auth")
            case "${2:-}" in
                "login"|"refresh") return 0 ;;
            esac
            ;;
        "repo"|"r")
            case "${2:-}" in
                "create"|"clone"|"fork") return 0 ;;
                "list")
                    # gh repo list requires --json for non-interactive output (--limit alone still produces table format)
                    if [[ ! " ${*:2} " =~ " --json " ]] && [[ ! " ${*:2} " =~ " -J " ]]; then
                        return 0
                    fi
                    ;;
            esac
            ;;
        "pr"|"pull-request")
            case "${2:-}" in
                "create")
                    # gh pr create is non-interactive when both title and body are provided
                    # (GH_PROMPT_DISABLED=1 handles confirmation prompts)
                    local has_title=false
                    local has_body=false

                    if [[ " ${*:2} " =~ " --title " ]] || [[ " ${*:2} " =~ " -t " ]]; then
                        has_title=true
                    fi
                    if [[ " ${*:2} " =~ " --body " ]] || [[ " ${*:2} " =~ " -b " ]] || \
                       [[ " ${*:2} " =~ " --body-file " ]] || [[ " ${*:2} " =~ " -F " ]] || \
                       [[ " ${*:2} " =~ " --fill " ]] || [[ " ${*:2} " =~ " --fill-first " ]]; then
                        has_body=true
                    fi

                    if $has_title && $has_body; then
                        return 1  # Non-interactive - both title and body provided
                    fi
                    return 0  # Interactive - missing title or body, will open editor
                    ;;
                "list")
                    # gh pr list requires --json for non-interactive output (--limit alone still produces table format)
                    if [[ ! " ${*:2} " =~ " --json " ]] && [[ ! " ${*:2} " =~ " -J " ]]; then
                        return 0
                    fi
                    ;;
                "checkout") return 0 ;;
            esac
            ;;
        "issue"|"i")
            case "${2:-}" in
                "create")
                    # gh issue create is non-interactive when both title and body are provided
                    # (GH_PROMPT_DISABLED=1 handles confirmation prompts)
                    local has_title=false
                    local has_body=false

                    if [[ " ${*:2} " =~ " --title " ]] || [[ " ${*:2} " =~ " -t " ]]; then
                        has_title=true
                    fi
                    if [[ " ${*:2} " =~ " --body " ]] || [[ " ${*:2} " =~ " -b " ]] || \
                       [[ " ${*:2} " =~ " --body-file " ]] || [[ " ${*:2} " =~ " -F " ]]; then
                        has_body=true
                    fi

                    if $has_title && $has_body; then
                        return 1  # Non-interactive - both title and body provided
                    fi
                    return 0  # Interactive - missing title or body, will open editor
                    ;;
                "list")
                    # gh issue list requires --json for non-interactive output (--limit alone still produces table format)
                    if [[ ! " ${*:2} " =~ " --json " ]] && [[ ! " ${*:2} " =~ " -J " ]]; then
                        return 0
                    fi
                    ;;
                "edit") return 0 ;;
            esac
            ;;
        "release")
            case "${2:-}" in
                "list")
                    # gh release list requires --json for non-interactive output (--limit alone still produces table format)
                    if [[ ! " ${*:2} " =~ " --json " ]] && [[ ! " ${*:2} " =~ " -J " ]]; then
                        return 0
                    fi
                    ;;
            esac
            ;;
        "gist")
            case "${2:-}" in
                "list")
                    # gh gist list requires --json for non-interactive output (--limit alone still produces table format)
                    if [[ ! " ${*:2} " =~ " --json " ]] && [[ ! " ${*:2} " =~ " -J " ]]; then
                        return 0
                    fi
                    ;;
            esac
            ;;
        "run")
            case "${2:-}" in
                "list")
                    # gh run list requires --json for non-interactive output (--limit alone still produces table format)
                    if [[ ! " ${*:2} " =~ " --json " ]] && [[ ! " ${*:2} " =~ " -J " ]]; then
                        return 0
                    fi
                    ;;
            esac
            ;;
        "workflow")
            case "${2:-}" in
                "list")
                    # gh workflow list requires --json for non-interactive output (--limit alone still produces table format)
                    if [[ ! " ${*:2} " =~ " --json " ]] && [[ ! " ${*:2} " =~ " -J " ]]; then
                        return 0
                    fi
                    ;;
            esac
            ;;
    esac
    return 1
}

# ===============================================================================
# REPOSITORY EXTRACTION - Parse repository from command arguments
# ===============================================================================

# Extract repository identifier from GitHub CLI command arguments
# Supports both --repo flag and positional repo arguments
# Args: $1+ - Command arguments
# Returns: Repository identifier (owner/repo) or empty string if not found
extract_repository_from_arguments() {
    local args=("$@")

    # Look for --repo flag
    for i in "${!args[@]}"; do
        if [[ "${args[$i]}" == "--repo" || "${args[$i]}" == "-R" ]]; then
            if (( i + 1 < ${#args[@]} )); then
                echo "${args[$i+1]}"
                return 0
            fi
        fi
    done

    # Look for repo as argument
    if [[ "${args[0]:-}" =~ ^(repo|r|issue|i|pr|pull-request|release|gist)$ ]] && [[ "${args[1]:-}" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]; then
        echo "${args[1]}"
        return 0
    fi

    return 1
}

# ===============================================================================
# REPOSITORY SAFETY CHECK - Determine if repository allows write operations
# ===============================================================================

# Check if a repository is safe for write operations based on ownership
# Protected repositories (Microsoft) are blocked, user repositories are allowed
# Args: $1 - Repository identifier (owner/repo format)
# Returns: 0 if safe for writes, 1 if protected/blocked
is_repository_safe_for_writes() {
    local repo="$1"

    if [[ -z "$repo" ]]; then
        return 0  # No repo specified, assume current repo is safe
    fi

    # Extract owner
    local owner
    if [[ "$repo" =~ ^[^/]+/([^/]+)/ ]]; then
        owner="${BASH_REMATCH[1]}"
    elif [[ "$repo" =~ ^([^/]+)/ ]]; then
        owner="${BASH_REMATCH[1]}"
    else
        return 1
    fi

    # Check if owner is allowed
    if [[ ",$ALLOWED_GITHUB_USERS," == *",$owner,"* ]] || [[ ",$ALLOWED_GITHUB_ORGS," == *",$owner,"* ]]; then
        return 0
    else
        return 1
    fi
}

# ===============================================================================
# UPSTREAM OPERATION DETECTION - Identify potentially dangerous write operations
# ===============================================================================

# Determine if a GitHub CLI operation could affect upstream repositories
# Only write operations are checked; read operations are always allowed
# Args: $1 - Command name, $2+ - Command arguments
# Returns: 0 if upstream operation (should be blocked), 1 if safe
is_upstream_write_operation() {
    local cmd="$1"
    shift
    local args=("$@")

    # Extract repo
    local repo
    repo=$(extract_repository_from_arguments "$cmd" "$@")

    # Only check repo safety for write operations, not read operations
    # Read operations (view, list, status, etc.) are allowed on any repo

    # Commands that could affect upstream (write operations only)
    case "$cmd" in
        "issue"|"i")
            case "${args[0]:-}" in
                "create"|"edit"|"close"|"reopen"|"lock"|"unlock"|"transfer")
                    # Check if repo is safe for write operations
                    if ! is_repository_safe_for_writes "$repo"; then
                        return 0
                    fi
                    ;;
            esac
            ;;
        "pr"|"pull-request")
            case "${args[0]:-}" in
                "create"|"edit"|"close"|"reopen"|"merge"|"ready"|"draft"|"review")
                    # Check if repo is safe for write operations
                    if ! is_repository_safe_for_writes "$repo"; then
                        return 0
                    fi
                    ;;
            esac
            ;;
        "repo"|"r")
            case "${args[0]:-}" in
                "create"|"delete"|"archive"|"unarchive"|"edit"|"fork"|"transfer")
                    # Check if repo is safe for write operations
                    if ! is_repository_safe_for_writes "$repo"; then
                        return 0
                    fi
                    ;;
                # view, clone are read operations - allowed on any repo
            esac
            ;;
        "release")
            case "${args[0]:-}" in
                "create"|"edit"|"delete")
                    # Check if repo is safe for write operations
                    if ! is_repository_safe_for_writes "$repo"; then
                        return 0
                    fi
                    ;;
                # view is read operation - allowed on any repo
            esac
            ;;
        "gist")
            case "${args[0]:-}" in
                "create"|"edit"|"delete")
                    # Check if repo is safe for write operations
                    if ! is_repository_safe_for_writes "$repo"; then
                        return 0
                    fi
                    ;;
            esac
            ;;
    esac

    return 1
}

# ===============================================================================
# MAIN WRAPPER LOGIC - Command processing and protection enforcement
# ===============================================================================

# Main entry point for GitHub CLI safe wrapper
# Orchestrates all protection checks and command execution
# Args: $1+ - Complete command line arguments passed to wrapper
main_wrapper_logic() {
    # Check if original gh exists
    if ! command -v "$PATH_TO_ORIGINAL_GH" >/dev/null 2>&1; then
        print_error_message "GitHub CLI not found at: $PATH_TO_ORIGINAL_GH"
        exit 1
    fi

    # Remove 'gh' if present as first argument (skill wrapper pattern)
    if [[ "${1:-}" == "gh" ]]; then
        shift
    fi

    # No arguments - pass through
    if [[ $# -eq 0 ]]; then
        exec "$PATH_TO_ORIGINAL_GH" "$@"
    fi

    local cmd="$1"

    # Help and version commands - pass through (before shift)
    if [[ "$cmd" == "--help" || "$cmd" == "-h" || "$cmd" == "help" || "$cmd" == "--version" || "$cmd" == "-v" ]]; then
        exec "$PATH_TO_ORIGINAL_GH" "$@"
    fi

    shift

    # Check for upstream operations FIRST (before interactive check)
    # This ensures write operations on protected repos are blocked properly
    if is_upstream_write_operation "$cmd" "$@"; then
        local repo
        repo=$(extract_repository_from_arguments "$cmd" "$@")

        print_error_message "🚫 UPSTREAM OPERATION BLOCKED: gh $cmd $*"
        print_error_message ""
        if [[ -n "$repo" ]]; then
            # Check if it's a Microsoft repo
            if [[ ",$PROTECTED_MICROSOFT_REPOS," == *",$repo,"* ]]; then
                print_error_message "❌ MICROSOFT REPOSITORY PROTECTION:"
                print_error_message "  Repository '$repo' is a Microsoft repository"
                print_error_message "  Write operations on Microsoft repos are blocked for LLM agents"
                print_error_message ""
                print_error_message "📖 LLM AGENT GUIDANCE:"
                print_error_message "  • Read operations (view, list, status) are allowed on Microsoft repos"
                print_error_message "  • Use 'gh issue list --repo $repo' to read issues"
                print_error_message "  • Use 'gh pr list --repo $repo' to read pull requests"
                print_error_message "  • Create issues/PRs in your own fork instead"
                print_skill_hint "D3" "See references/safe-commands.md for reading from protected repos"
                print_skill_hint "D3" "See references/safe-commands.md for creating issues in your repos"
            else
                print_error_message "Repository '$repo' is not in allowed users/orgs: $ALLOWED_GITHUB_USERS, $ALLOWED_GITHUB_ORGS"
                print_error_message ""
                print_error_message "📖 LLM AGENT GUIDANCE:"
                print_error_message "  • Only write to repositories you own or are explicitly allowed"
                print_error_message "  • Use 'gh repo create' to create your own repository"
              print_error_message "  • Fork the repository there if you need to make changes"
                print_skill_hint "D3" "See references/protected-repos.md for complete protection rules"
            fi
        else
            print_error_message "This operation could affect upstream repositories and is blocked."
        fi
        print_error_message ""
        print_error_message "💡 To override (human only): ALLOW_UPSTREAM=true gh $cmd $*"
        exit 1
    fi

    # Check for interactive commands (only after checking upstream operations)
    if is_github_command_interactive "$cmd" "$@"; then
        local subcmd="${1:-}"
        print_error_message "🚫 INTERACTIVE COMMAND BLOCKED: gh $cmd $*"
        print_error_message ""
        print_error_message "This command requires user interaction and will hang LLM agents."
        print_error_message ""
        print_error_message "🔧 HOW TO FIX (LLM AGENTS READ THIS):"
        case "$cmd" in
            "extension"|"ext")
                if [[ "$subcmd" == "browse" ]]; then
                    print_error_message "  ✓ Use: gh extension list"
                    print_error_message "  ✓ Use: gh extension search <name>"
                    print_skill_hint "D3" "See references/safe-commands.md for complete command reference"
                fi
                ;;
            "browse")
                print_error_message "  ✓ Use: gh browse --no-browser"
                print_error_message "    (This prints the URL without opening a browser)"
                print_skill_hint "D3" "See references/safe-commands.md for more examples"
                ;;
            "auth")
                if [[ "$subcmd" == "login" ]]; then
                    print_error_message "  ✗ Authentication MUST be done by a human operator"
                    print_error_message "  ✗ Cannot be automated - security requirement"
                    print_error_message ""
                    print_error_message "  💡 Human operator bypass: ALLOW_INTERACTIVE=true gh $cmd $*"
                    print_skill_hint "D3" "See references/error-handling.md for authentication guidance"
                elif [[ "$subcmd" == "refresh" ]]; then
                    print_error_message "  ✗ Token refresh MUST be done by a human operator"
                    print_error_message ""
                    print_error_message "  💡 Human operator bypass: ALLOW_INTERACTIVE=true gh $cmd $*"
                fi
                ;;
            "repo"|"r")
                if [[ "$subcmd" == "create" ]]; then
                    print_error_message "  ✓ Use: gh repo create <name> --public --clone=false"
                    print_error_message "    (Provide --public or --private and --clone=false to avoid prompts)"
                    print_skill_hint "D3" "See references/safe-commands.md for repository creation examples"
                elif [[ "$subcmd" == "list" ]]; then
                    print_error_message "  ✓ Use: gh repo list --json name,url --limit 10"
                    print_error_message "  ✓ Or: gh repo list --json name,visibility,updatedAt"
                    print_error_message "    (MUST use --json for non-interactive output)"
                    print_skill_hint "D3" "See references/safe-commands.md for all --json field options"
                fi
                ;;
            "issue"|"i")
                if [[ "$subcmd" == "create" ]]; then
                    print_error_message "  ✓ Use: gh issue create --title 'Your Title' --body 'Your description'"
                    print_error_message "  ✓ Or:  gh issue create --title 'Your Title' --body-file description.md"
                    print_error_message ""
                    print_error_message "  IMPORTANT: Both --title AND --body (or --body-file) are REQUIRED"
                    print_error_message "  Without both, the command opens an editor which blocks automation"
                    print_skill_hint "D3" "See references/safe-commands.md for issue creation examples"
                elif [[ "$subcmd" == "list" ]]; then
                    print_error_message "  ✓ Use: gh issue list --json number,title --limit 10"
                    print_error_message "  ✓ Or: gh issue list --json number,title,state,url"
                    print_error_message "    (MUST use --json for non-interactive output)"
                    print_skill_hint "D3" "See references/safe-commands.md for all --json field options"
                elif [[ "$subcmd" == "edit" ]]; then
                    print_error_message "  ✗ 'gh issue edit' always opens an editor - cannot be automated"
                    print_error_message "  ✓ Use GitHub API or web interface instead"
                    print_skill_hint "D3" "See references/error-handling.md for alternatives"
                fi
                ;;
            "pr"|"pull-request")
                if [[ "$subcmd" == "create" ]]; then
                    print_error_message "  ✓ Use: gh pr create --title 'Your Title' --body 'Your description'"
                    print_error_message "  ✓ Or: gh pr create --title 'Your Title' --body-file description.md"
                    print_error_message "  ✓ Or: gh pr create --fill (auto-generates from commits)"
                    print_error_message ""
                    print_error_message "  IMPORTANT: Both --title AND --body/--fill are REQUIRED"
                    print_error_message "  Without both, the command opens an editor which blocks automation"
                    print_skill_hint "D3" "See references/safe-commands.md for PR creation examples"
                elif [[ "$subcmd" == "list" ]]; then
                    print_error_message "  ✓ Use: gh pr list --json number,title --limit 10"
                    print_error_message "  ✓ Or: gh pr list --json number,title,state,url"
                    print_error_message "    (MUST use --json for non-interactive output)"
                    print_skill_hint "D3" "See references/safe-commands.md for all --json field options"
                fi
                ;;
            "release")
                if [[ "$subcmd" == "list" ]]; then
                    print_error_message "  ✓ Use: gh release list --json tagName,name --limit 10"
                    print_error_message "  ✓ Or: gh release list --json tagName,publishedAt,url"
                    print_error_message "    (MUST use --json for non-interactive output)"
                    print_skill_hint "D3" "See references/safe-commands.md for all --json field options"
                fi
                ;;
            "gist")
                if [[ "$subcmd" == "list" ]]; then
                    print_error_message "  ✓ Use: gh gist list --json id,description --limit 10"
                    print_error_message "  ✓ Or: gh gist list --json id,files,updatedAt"
                    print_error_message "    (MUST use --json for non-interactive output)"
                    print_skill_hint "D3" "See references/safe-commands.md for all --json field options"
                fi
                ;;
            "run")
                if [[ "$subcmd" == "list" ]]; then
                    print_error_message "  ✓ Use: gh run list --json databaseId,status --limit 10"
                    print_error_message "  ✓ Or: gh run list --json databaseId,conclusion,url"
                    print_error_message "    (MUST use --json for non-interactive output)"
                    print_skill_hint "D3" "See references/safe-commands.md for all --json field options"
                fi
                ;;
            "workflow")
                if [[ "$subcmd" == "list" ]]; then
                    print_error_message "  ✓ Use: gh workflow list --json id,name --limit 10"
                    print_error_message "  ✓ Or: gh workflow list --json id,name,state"
                    print_error_message "    (MUST use --json for non-interactive output)"
                    print_skill_hint "D3" "See references/safe-commands.md for all --json field options"
                fi
                ;;
        esac
        exit 1
    fi

    # Set non-interactive environment
    export GH_PROMPT_DISABLED=true
    export GH_PAGER="cat"
    export GH_FORCE_TTY=false
    export NO_COLOR=true

    # Execute command
    exec "$PATH_TO_ORIGINAL_GH" "$cmd" "$@"
}

# Check for override
if [[ "${ALLOW_UPSTREAM:-}" == "true" ]]; then
    print_info_message "Upstream protection disabled by ALLOW_UPSTREAM=true"
    exec "$PATH_TO_ORIGINAL_GH" "$@"
fi

# Check for interactive bypass
if [[ "${ALLOW_INTERACTIVE:-}" == "true" ]]; then
    print_info_message "Interactive command protection disabled by ALLOW_INTERACTIVE=true"
    exec "$PATH_TO_ORIGINAL_GH" "$@"
fi

# Run main function
main_wrapper_logic "$@"
