#!/bin/bash
# Monitor trunner log file with smart completion detection
#
# ⚠️  IMPORTANT: This script MUST be run by a SUBAGENT for token efficiency.
#              The main agent/architect delegates log monitoring to avoid
#              token consumption from repeated log checks.
#
# Usage: monitor-trunner-log.sh [log_file] [max_checks] [needle_patterns...]
#
# Args:
#   log_file        - Path to log file (default: most recent /tmp/test_suite_output_tmux-runner-*.log)
#   max_checks      - Maximum number of checks (default: 30)
#   needle_patterns - Space-separated grep patterns to detect completion
#                    If not provided, uses DEFAULT_NEEDLES below
#
# Examples:
#   # Subagent monitors most recent log with default needles
#   monitor-trunner-log.sh
#
#   # Subagent monitors specific log with custom max checks
#   monitor-trunner-log.sh /tmp/test_suite_output_tmux-runner-XYZ.log 50
#
#   # Subagent monitors with custom completion needles (override defaults)
#   monitor-trunner-log.sh "" 30 "Custom Pattern|Another Pattern"
#
# Exit codes:
#   0 - Needle detected (completion)
#   1 - Max checks reached without needle detection
#   2 - Log file not found
#
# Monitoring pattern (from $TmuxProtectedExecution skill):
#   - Sleep: configurable (default: 5 seconds, NEVER > 10s)
#   - Tail: configurable (default: 20 lines, NEVER > 20 lines)
#   - For loop with explicit counter
#   - Grep -q for efficient pattern matching

set -euo pipefail

# Configurable parameters
declare -A CONFIG=(
    [sleep_seconds]=5    # Sleep duration between checks (NEVER > 10)
    [tail_lines]=20     # Number of log lines to show per check (NEVER > 20)
)

# Default completion needles (comprehensive markers)
DEFAULT_NEEDLES="Main Branch Deployment Complete|✓ Deployment complete|Setup completed successfully|Rebuild.*Complete|Cloudflare tunnel started|ERROR:|Failed|fatal"

# Determine log file
LOG_FILE="${1:-}"

if [[ -z "$LOG_FILE" ]]; then
    # Find most recent trunner log
    LOG_FILE=$(ls -t /tmp/test_suite_output_tmux-runner-*.log 2>/dev/null | head -1)
    if [[ -z "$LOG_FILE" ]]; then
        echo "❌ ERROR: No trunner log files found in /tmp/" >&2
        exit 2
    fi
fi

if [[ ! -f "$LOG_FILE" ]]; then
    echo "❌ ERROR: Log file not found: $LOG_FILE" >&2
    exit 2
fi

# Max checks (default 30, second arg)
MAX_CHECKS="${2:-30}"

# Build needle pattern from remaining args or use defaults
if [[ $# -gt 2 ]]; then
    shift 2
    NEEDLE="$*"
else
    NEEDLE="$DEFAULT_NEEDLES"
fi

# Extract session ID from log file name
SESSION_ID=$(basename "$LOG_FILE" .log | sed 's/test_suite_output_//')

# Report to invoker (main agent/architect)
echo "📋 SUBAGENT REPORT: Starting log monitoring"
echo "   Log file: $LOG_FILE"
echo "   Session ID: $SESSION_ID"
echo "   Max checks: $MAX_CHECKS"
echo "   Needle: $NEEDLE"
echo "   Sleep seconds: ${CONFIG[sleep_seconds]}"
echo "   Tail lines: ${CONFIG[tail_lines]}"
echo ""

# Track previous log size to detect stagnation
prev_size=0
stagnant_count=0
MAX_STAGNANT_COUNT=3  # After 3 checks with no growth, assume script is dead

# Smart monitoring loop (from $TmuxProtectedExecution skill)
for ((i=1; i<=MAX_CHECKS; i++)); do
    sleep "${CONFIG[sleep_seconds]}"
    echo "=== Check $i/$MAX_CHECKS ==="

    # Check if tmux session still exists
    if ! tmux has-session -t "$SESSION_ID" 2>/dev/null; then
        echo ""
        echo "🚨 SUBAGENT REPORT: Tmux session terminated - script has ended"
        echo "📋 Last 50 lines of log:"
        tail -50 "$LOG_FILE"

        # Check if termination was successful (look for success markers)
        if grep -qE "$NEEDLE" "$LOG_FILE" 2>/dev/null; then
            echo ""
            echo "✅ SUBAGENT REPORT: Session terminated with success markers detected"
            echo "📝 Matched lines:"
            grep -E "$NEEDLE" "$LOG_FILE" | tail -5
            exit 0
        else
            echo ""
            echo "❌ SUBAGENT REPORT: Session terminated WITHOUT success markers - possible crash/failure"
            echo "⚠️  Script may have crashed before completion"
            exit 1
        fi
    fi

    # Get current log size
    current_size=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)

    # Show last N lines
    tail -"${CONFIG[tail_lines]}" "$LOG_FILE"

    # Check for needle (completion marker)
    if grep -qE "$NEEDLE" "$LOG_FILE" 2>/dev/null; then
        echo ""
        echo "✅ SUBAGENT REPORT: Needle detected - returning to invoker"

        # Show what matched (last 5 matches)
        echo "📝 Matched lines:"
        grep -E "$NEEDLE" "$LOG_FILE" | tail -5
        exit 0
    fi

    # Detect log stagnation (no new content being added)
    if [[ "$current_size" -eq "$prev_size" ]]; then
        ((stagnant_count++))
        echo "⚠️  Log file stagnant (no growth) - check $stagnant_count/$MAX_STAGNANT_COUNT"

        if [[ $stagnant_count -ge $MAX_STAGNANT_COUNT ]]; then
            echo ""
            echo "🚨 SUBAGENT REPORT: Log file stagnant for $stagnant_count consecutive checks"
            echo "⚠️  Script may have hung or crashed without terminating session"
            echo "📋 Last 50 lines of log:"
            tail -50 "$LOG_FILE"
            echo ""
            echo "💡 RECOMMENDATION: Check if script is stuck or waiting for input"
            echo "   Consider killing session: tmux kill-session -t $SESSION_ID"
            exit 1
        fi
    else
        # Log grew, reset stagnant counter
        stagnant_count=0
        echo "📊 Log size: $current_size bytes (+$((current_size - prev_size)) bytes)"
    fi

    prev_size=$current_size
done

# Max checks reached
echo ""
echo "⚠️  SUBAGENT REPORT: Max checks reached - needle not found"
echo "📋 Last 50 lines of log:"
tail -50 "$LOG_FILE"
exit 1
