#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

# Function to display usage instructions
usage() {
  echo "Usage: $0 [--project <target_project_directory>] [--help]"
  echo "  If --project is omitted, the current directory is used."
  echo "  Creates a symlink 'scripts' in the target project pointing to the local scripts dir,"
  echo "  adds 'scripts/' and 'scripts' to the target project's .gitignore file, and commits the change."
  exit 1
}

# --- Argument Parsing ---
TARGET_PROJECT_DIR=""

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --project)
      if [[ -z "$2" || "$2" == --* ]]; then
          echo "Error: --project requires a directory path." >&2
          usage
      fi
      TARGET_PROJECT_DIR="$2"; shift 2 ;;
    --help) usage ;; # Call usage function if --help is provided
    *) echo "Unknown parameter passed: $1"; usage ;;
  esac
done

# --- Determine Target Directory and Confirm ---
if [ -z "$TARGET_PROJECT_DIR" ]; then
  TARGET_PROJECT_DIR=$(pwd)
  echo "No --project specified. Using current directory: $TARGET_PROJECT_DIR"
  read -p "Is this correct? (y/N) " -r confirm
  echo # Add a newline after the prompt
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Operation cancelled by user."
    exit 1
  fi
fi

# --- Path Handling ---
# Get the absolute path of the script's directory
# Resolve potential symlinks first to get the actual script file path
# First find the script location
if [ -L "${BASH_SOURCE[0]}" ]; then
    # Script is called via symlink
    SCRIPT_LOCATION=$(readlink -f "${BASH_SOURCE[0]}")
else
    # Script is called directly
    SCRIPT_LOCATION="${BASH_SOURCE[0]}"
fi
SCRIPT_DIR=$(dirname "$SCRIPT_LOCATION")
# Find the llm-rules root directory by going up until we find the scripts directory
CURRENT_DIR="$SCRIPT_DIR"
while [ "$CURRENT_DIR" != "/" ]; do
    # Skip .vscode/skills directories - we want the main scripts directory at llm-rules root
    if [[ "$CURRENT_DIR" == *".vscode/skills"* ]]; then
        CURRENT_DIR=$(dirname "$CURRENT_DIR")
        continue
    fi
    if [ -d "$CURRENT_DIR/scripts" ] && [ -f "$CURRENT_DIR/scripts/README.md" ] && [ -f "$CURRENT_DIR/scripts/cf-launcher.sh" ]; then
        GLOBAL_SCRIPTS_DIR="$CURRENT_DIR/scripts"
        break
    fi
    CURRENT_DIR=$(dirname "$CURRENT_DIR")
done

# Fallback if not found
if [ -z "$GLOBAL_SCRIPTS_DIR" ]; then
    echo "Error: Could not find the llm-rules/scripts directory"
    exit 1
fi

# Resolve the absolute path for the target project directory
# Ensure it's absolute before realpath
if [[ "$TARGET_PROJECT_DIR" != /* ]]; then
  TARGET_PROJECT_DIR="$(pwd)/$TARGET_PROJECT_DIR"
fi
# Use realpath -m to handle non-existent paths temporarily if needed,
# but we check existence right after.
TARGET_PROJECT_DIR=$(realpath -m "$TARGET_PROJECT_DIR")

# Check if target project directory exists
if [ ! -d "$TARGET_PROJECT_DIR" ]; then
  echo "Error: Target project directory does not exist: $TARGET_PROJECT_DIR"
  exit 1
fi

# Check if source scripts directory exists
if [ ! -d "$GLOBAL_SCRIPTS_DIR" ]; then
  echo "Error: Source directory scripts does not exist in $SCRIPT_DIR"
  exit 1
fi

TARGET_SCRIPTS_LINK="$TARGET_PROJECT_DIR/scripts" # Changed from rules

# --- Symlink Creation ---
# Check if the target link path already exists
if [ -e "$TARGET_SCRIPTS_LINK" ]; then
  if [ -L "$TARGET_SCRIPTS_LINK" ]; then
    # If it's a symlink, check if it points to the correct location
    LINK_TARGET=$(readlink "$TARGET_SCRIPTS_LINK")
    if [ "$LINK_TARGET" == "$GLOBAL_SCRIPTS_DIR" ]; then
      echo "Symlink '$TARGET_SCRIPTS_LINK' already exists and points correctly."
    else
      echo "Warning: Symlink '$TARGET_SCRIPTS_LINK' exists but points to '$LINK_TARGET'. Removing and recreating."
      rm "$TARGET_SCRIPTS_LINK"
      ln -s "$GLOBAL_SCRIPTS_DIR" "$TARGET_SCRIPTS_LINK"
      echo "Created symlink: '$TARGET_SCRIPTS_LINK' -> '$GLOBAL_SCRIPTS_DIR'"
    fi
  else
    # If it exists but is not a symlink (e.g., a directory or file), remove it forcibly
    echo "Warning: '$TARGET_SCRIPTS_LINK' already exists but is not a symlink. Removing it forcibly."
    rm -rf "$TARGET_SCRIPTS_LINK"
    ln -s "$GLOBAL_SCRIPTS_DIR" "$TARGET_SCRIPTS_LINK"
    echo "Created symlink: '$TARGET_SCRIPTS_LINK' -> '$GLOBAL_SCRIPTS_DIR'"
  fi
else
  # Create the symlink
  ln -s "$GLOBAL_SCRIPTS_DIR" "$TARGET_SCRIPTS_LINK"
  echo "Created symlink: '$TARGET_SCRIPTS_LINK' -> '$GLOBAL_SCRIPTS_DIR'"
fi


# --- Gitignore and Commit Handling ---
GITIGNORE_PATH="$TARGET_PROJECT_DIR/.gitignore"
SCRIPTS_DIR_ENTRY="scripts/"  # Changed from rules/
SCRIPTS_LINK_ENTRY="scripts" # Changed from rules
GITIGNORE_MODIFIED=false

# Check if inside a git repository
if ! git -C "$TARGET_PROJECT_DIR" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Warning: Target project '$TARGET_PROJECT_DIR' is not a git repository. Skipping git operations."
    echo "Scripts symlink setup complete for project: $TARGET_PROJECT_DIR"
    exit 0
fi

# Check if .gitignore exists and add entries if needed
if [ -f "$GITIGNORE_PATH" ]; then
  GITIGNORE_HAD_DIR_ENTRY=true
  GITIGNORE_HAD_LINK_ENTRY=true

  # Check for directory pattern
  if ! grep -qxF "$SCRIPTS_DIR_ENTRY" "$GITIGNORE_PATH"; then
    echo "" >> "$GITIGNORE_PATH"
    echo "# Ignore local scripts directory and symlink" >> "$GITIGNORE_PATH"
    echo "$SCRIPTS_DIR_ENTRY" >> "$GITIGNORE_PATH"
    echo "Added '$SCRIPTS_DIR_ENTRY' to $GITIGNORE_PATH."
    GITIGNORE_MODIFIED=true
    GITIGNORE_HAD_DIR_ENTRY=false
  fi

  # Check for symlink pattern
  if ! grep -qxF "$SCRIPTS_LINK_ENTRY" "$GITIGNORE_PATH"; then
     # Append if missing, add comment only if the dir entry wasn't just added
    if $GITIGNORE_HAD_DIR_ENTRY; then
        echo "" >> "$GITIGNORE_PATH"
        echo "# Ignore local scripts symlink specifically" >> "$GITIGNORE_PATH"
    fi
    echo "$SCRIPTS_LINK_ENTRY" >> "$GITIGNORE_PATH"
    echo "Added '$SCRIPTS_LINK_ENTRY' (symlink) to $GITIGNORE_PATH."
    GITIGNORE_MODIFIED=true
    GITIGNORE_HAD_LINK_ENTRY=false
  fi

  if $GITIGNORE_HAD_DIR_ENTRY && $GITIGNORE_HAD_LINK_ENTRY && ! $GITIGNORE_MODIFIED ; then
     echo "'$SCRIPTS_DIR_ENTRY' and '$SCRIPTS_LINK_ENTRY' already exist in $GITIGNORE_PATH."
  fi

else
  # Create .gitignore and add both entries
  echo "# Ignore local scripts directory and symlink" > "$GITIGNORE_PATH"
  echo "$SCRIPTS_DIR_ENTRY" >> "$GITIGNORE_PATH"
  echo "$SCRIPTS_LINK_ENTRY" >> "$GITIGNORE_PATH"
  echo "Created $GITIGNORE_PATH and added '$SCRIPTS_DIR_ENTRY' and '$SCRIPTS_LINK_ENTRY'."
  GITIGNORE_MODIFIED=true
fi

# --- Git Operations within Target Directory ---

ORIGINAL_DIR=$(pwd)
cd "$TARGET_PROJECT_DIR"

SCRIPTS_REMOVED_FROM_INDEX=false

# Check if scripts directory/symlink is tracked by git (use the link entry now)
if git ls-files --error-unmatch "$SCRIPTS_LINK_ENTRY" > /dev/null 2>&1; then
    echo "Warning: '$SCRIPTS_LINK_ENTRY' (symlink) is currently tracked by git. Removing from index."
    # Use the symlink name for removal, add -r for directories
    git rm --cached -r "$SCRIPTS_LINK_ENTRY" > /dev/null
    SCRIPTS_REMOVED_FROM_INDEX=true
    echo "Removed '$SCRIPTS_LINK_ENTRY' from git index."
fi

# Commit changes if .gitignore was modified or scripts were removed from index
if [ "$GITIGNORE_MODIFIED" = true ] || [ "$SCRIPTS_REMOVED_FROM_INDEX" = true ]; then
    echo "Staging .gitignore..."
    git add "$GITIGNORE_PATH"

    COMMIT_MSG="chore: Ignore local scripts symlink (scripts, scripts/) and update .gitignore"
    if [ "$SCRIPTS_REMOVED_FROM_INDEX" = true ]; then
        COMMIT_MSG="chore: Remove tracked local scripts symlink and update .gitignore (scripts, scripts/)"
    fi

    echo "Committing changes..."
    if git commit -m "$COMMIT_MSG"; then
        echo "Committed .gitignore changes related to scripts symlink."
    else
        echo "Warning: Failed to commit .gitignore changes for scripts symlink. Maybe no changes to commit?"
    fi
elif git diff --quiet --exit-code "$GITIGNORE_PATH"; then
    # Check specifically if only the .gitignore has unstaged changes (e.g. whitespace)
    if ! git diff --staged --quiet --exit-code; then
        echo "No relevant changes to commit for scripts symlink."
    else
        echo "Warning: .gitignore has unstaged changes not made by this script. Please review and commit manually."
    fi
else
    echo "No relevant changes to commit regarding scripts/ or .gitignore."
fi

# Return to original directory
cd "$ORIGINAL_DIR"

echo "Scripts symlink setup complete for project: $TARGET_PROJECT_DIR"
exit 0
