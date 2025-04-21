#!/bin/bash
# 🚀 Flutter Version Bump & Build Script (Super Enhanced)
# Author: Final Enhanced Version

# Enable strict mode
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

PUBSPEC="pubspec.yaml"
BACKUP_FILE="${PUBSPEC}.script_backup"
TEMP_FILE=".${PUBSPEC}.tmp"

# Helper Functions
function error_exit {
  echo -e "${RED}❌ $1${NC}" >&2

  # Restore from backup if it exists
  if [ -f "$BACKUP_FILE" ]; then
    cp "$BACKUP_FILE" "$PUBSPEC"
    rm -f "$BACKUP_FILE"
    echo -e "${YELLOW}Restored pubspec.yaml from backup.${NC}"
  fi

  cleanup
  exit 1
}

function warning {
  echo -e "${YELLOW}⚠️ $1${NC}"
}

function info {
  echo -e "${GREEN}➡️ $1${NC}"
}

function debug {
  if [ "$DEBUG" = true ]; then
    echo -e "${BLUE}🔍 $1${NC}"
  fi
}

function section {
  echo -e "\n${CYAN}== $1 ==${NC}"
}

function cleanup {
  # Clean up backup and temp files
  debug "Running cleanup..."
  if [ -f "$BACKUP_FILE" ]; then
    debug "Removing backup file $BACKUP_FILE"
    rm -f "$BACKUP_FILE"
  fi
  if [ -f "$TEMP_FILE" ]; then
    debug "Removing temp file $TEMP_FILE"
    rm -f "$TEMP_FILE"
  fi
}

# Check if a command exists
function command_exists {
  command -v "$1" >/dev/null 2>&1
}

# Check if string contains substring
function contains {
  string="$1"
  substring="$2"
  if [[ "$string" == *"$substring"* ]]; then
    return 0
  else
    return 1
  fi
}

# GitHub functions
function check_gh_auth {
  if ! command_exists gh; then
    warning "GitHub CLI (gh) not found. Please install it to create repositories."
    echo "You can install it from: https://cli.github.com/"
    return 1
  fi

  # Check if authenticated
  if ! gh auth status &>/dev/null; then
    warning "GitHub CLI not authenticated. Please run 'gh auth login' first."
    read -rp "Would you like to authenticate now? (y/n): " AUTH_NOW
    if [[ "$AUTH_NOW" =~ ^[Yy] ]]; then
      gh auth login || return 1
    else
      return 1
    fi
  fi

  return 0
}

function create_github_repo {
  local repo_name="$1"
  local is_private="$2"
  local description="$3"

  # Check if gh is available and authenticated
  if ! check_gh_auth; then
    return 1
  fi

  # Check if repo already exists
  if gh repo view "$repo_name" &>/dev/null; then
    warning "Repository '$repo_name' already exists on GitHub."
    read -rp "Would you like to use this existing repository? (y/n): " USE_EXISTING
    if [[ "$USE_EXISTING" =~ ^[Yy] ]]; then
      # Get the correct URL for the existing repo
      local github_username=$(gh api user --jq '.login')
      if [ -n "$github_username" ]; then
        info "Using existing GitHub repository: $repo_name"
        return 0
      else
        warning "Failed to get GitHub username."
        return 1
      fi
    else
      return 1
    fi
  fi

  # Set visibility flag
  if [ "$is_private" = "true" ]; then
    private_flag="--private"
  else
    private_flag="--public"
  fi

  # Set description flag
  if [ -n "$description" ]; then
    desc_flag="--description \"$description\""
  else
    desc_flag=""
  fi

  info "Creating GitHub repository: $repo_name"

  # Using GitHub CLI to create repo
  if eval gh repo create "$repo_name" $private_flag $desc_flag --source=. --remote=origin; then
    info "GitHub repository created successfully!"
    return 0
  else
    warning "Failed to create GitHub repository. Please check your GitHub CLI setup."
    return 1
  fi
}

function setup_github {
  # Check if this is already a git repo
  if [ -d .git ]; then
    # Check if remote 'origin' exists
    if git remote get-url origin &>/dev/null; then
      info "Git repository already set up with remote origin."
      return 0
    fi
  else
    # Initialize git repo
    info "Initializing git repository..."
    git init || error_exit "Failed to initialize git repository"
  fi

  # Get project name from directory
  REPO_NAME=$(basename "$(pwd)")

  section "GitHub Repository Setup"

  # Offer to create GitHub repo
  read -rp "Would you like to create a GitHub repository for this project? (y/n): " CREATE_REPO
  if [[ "$CREATE_REPO" =~ ^[Yy] ]]; then
    read -rp "Repository name [$REPO_NAME]: " CUSTOM_REPO_NAME
    REPO_NAME=${CUSTOM_REPO_NAME:-$REPO_NAME}

    read -rp "Private repository? (y/n): " PRIVATE_REPO
    if [[ "$PRIVATE_REPO" =~ ^[Yy] ]]; then
      IS_PRIVATE="true"
    else
      IS_PRIVATE="false"
    fi

    read -rp "Repository description (optional): " REPO_DESC

    if create_github_repo "$REPO_NAME" "$IS_PRIVATE" "$REPO_DESC"; then
      # Remote should be set up by gh CLI, but let's verify
      if ! git remote get-url origin &>/dev/null; then
        # Try to add remote manually if not set
        local github_username=$(gh api user --jq '.login')
        if [ -n "$github_username" ]; then
          git remote add origin "https://github.com/$github_username/$REPO_NAME.git" ||
          warning "Failed to add remote. You may need to set it manually."
        else
          warning "Failed to get GitHub username. You may need to set up the remote manually."
        fi
      fi

      return 0
    else
      return 1
    fi
  else
    warning "Skipped GitHub repository creation."
    return 0
  fi
}

function get_current_branch {
  git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main"
}

# Flutter build functions
function build_flutter_app {
  section "Flutter Build Options"

  # Check if Flutter is installed
  if ! command_exists flutter; then
    warning "Flutter command not found. Cannot build app."
    return 1
  fi

  # Get the available build options
  echo "Choose a build option:"
  echo "1) Build APK"
  echo "2) Build App Bundle (AAB)"
  echo "3) Build for iOS (macOS only)"
  echo "4) Build Web"
  echo "5) Skip build"

  read -rp "Select an option (1-5): " BUILD_OPTION

  case $BUILD_OPTION in
    1)
      echo -e "\n${GREEN}Building APK...${NC}"
      read -rp "Build mode [release/debug/profile] (default: release): " BUILD_MODE
      BUILD_MODE=${BUILD_MODE:-release}

      flutter build apk --$BUILD_MODE || {
        warning "APK build failed."
        return 1
      }

      # Show the location of the build
      APK_PATH="build/app/outputs/flutter-apk/app-$BUILD_MODE.apk"
      if [ -f "$APK_PATH" ]; then
        info "APK built successfully at: $APK_PATH"

        # Offer to rename the APK with version number
        read -rp "Rename APK to include version number? (y/n): " RENAME_APK
        if [[ "$RENAME_APK" =~ ^[Yy] ]]; then
          APP_NAME=$(grep -E "^[[:space:]]*name:" "$PUBSPEC" | sed -E "s/^[[:space:]]*name:[[:space:]]*//" | tr -d '"'\''')
          if [ -z "$APP_NAME" ]; then
            APP_NAME="app"
          fi

          NEW_APK_NAME="${APP_NAME}-${NEW_VERSION}+${NEW_BUILD}-${BUILD_MODE}.apk"
          NEW_APK_PATH="build/app/outputs/flutter-apk/$NEW_APK_NAME"

          cp "$APK_PATH" "$NEW_APK_PATH" &&
          info "APK copied to: $NEW_APK_PATH"
        fi
      fi
      ;;
    2)
      echo -e "\n${GREEN}Building App Bundle (AAB)...${NC}"
      flutter build appbundle || {
        warning "App Bundle build failed."
        return 1
      }

      # Show the location of the build
      AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
      if [ -f "$AAB_PATH" ]; then
        info "App Bundle built successfully at: $AAB_PATH"

        # Offer to rename the AAB with version number
        read -rp "Rename AAB to include version number? (y/n): " RENAME_AAB
        if [[ "$RENAME_AAB" =~ ^[Yy] ]]; then
          APP_NAME=$(grep -E "^[[:space:]]*name:" "$PUBSPEC" | sed -E "s/^[[:space:]]*name:[[:space:]]*//" | tr -d '"'\''')
          if [ -z "$APP_NAME" ]; then
            APP_NAME="app"
          fi

          NEW_AAB_NAME="${APP_NAME}-${NEW_VERSION}+${NEW_BUILD}-release.aab"
          NEW_AAB_PATH="build/app/outputs/bundle/release/$NEW_AAB_NAME"

          cp "$AAB_PATH" "$NEW_AAB_PATH" &&
          info "AAB copied to: $NEW_AAB_PATH"
        fi
      fi
      ;;
    3)
      if [[ "$OS_TYPE" == "mac" ]]; then
        echo -e "\n${GREEN}Building for iOS...${NC}"
        flutter build ios || {
          warning "iOS build failed."
          return 1
        }
        info "iOS build completed. Use Xcode to archive and distribute."
      else
        warning "iOS builds are only supported on macOS."
      fi
      ;;
    4)
      echo -e "\n${GREEN}Building for Web...${NC}"
      flutter build web || {
        warning "Web build failed."
        return 1
      }
      info "Web build completed at: build/web/"
      ;;
    5)
      info "Skipping build process."
      ;;
    *)
      warning "Invalid option. Skipping build."
      ;;
  esac

  return 0
}

# Parse command line arguments
function parse_arguments {
  # Initialize default values
  VERSION_BUMP=true
  VERSION_ARG=""
  BUILD_ARG=""
  BUILD_ONLY=false
  DEBUG=false

  while [[ $# -gt 0 ]]; do
    case $1 in
      -d|--debug)
        DEBUG=true
        ;;
      --build-only)
        BUILD_ONLY=true
        VERSION_BUMP=false
        ;;
      --no-build)
        NO_BUILD=true
        ;;
      --help)
        show_help
        exit 0
        ;;
      major|minor|patch)
        if [ -z "$VERSION_ARG" ]; then
          VERSION_ARG=$1
        fi
        ;;
      *)
        # Check if it's a version number or build number
        if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
          # It's a version number
          if [ -z "$VERSION_ARG" ]; then
            VERSION_ARG=$1
          fi
        elif [[ $1 =~ ^[0-9]+$ ]]; then
          # It's a build number
          if [ -z "$BUILD_ARG" ]; then
            BUILD_ARG=$1
          fi
        else
          warning "Unknown argument: $1"
        fi
        ;;
    esac
    shift
  done

  debug "VERSION_BUMP=$VERSION_BUMP, VERSION_ARG=$VERSION_ARG, BUILD_ARG=$BUILD_ARG, BUILD_ONLY=$BUILD_ONLY, DEBUG=$DEBUG"
}

function show_help {
  echo -e "${CYAN}Flutter Version Bump & Build Script - Help${NC}"
  echo ""
  echo "Usage: $0 [options] [version] [build-number]"
  echo ""
  echo "Options:"
  echo "  -d, --debug        Enable debug output"
  echo "  --build-only       Skip version bump and only build"
  echo "  --no-build         Skip build step"
  echo "  --help             Show this help message"
  echo ""
  echo "Version can be:"
  echo "  major              Bump major version (X.0.0)"
  echo "  minor              Bump minor version (x.X.0)"
  echo "  patch              Bump patch version (x.x.X)"
  echo "  x.y.z              Set specific version"
  echo ""
  echo "Examples:"
  echo "  $0 minor           # Bump minor version"
  echo "  $0 1.2.3           # Set version to 1.2.3"
  echo "  $0 minor 42        # Bump minor version and set build to 42"
  echo "  $0 --build-only    # Only build without version change"
}

# Main logic for version bump
function perform_version_bump {
  # Create a dedicated backup with unique name to avoid conflicts with sed
  cp "$PUBSPEC" "$BACKUP_FILE" || error_exit "Failed to create backup."
  debug "Backup created as $BACKUP_FILE"

  # Extract current version with stricter regex
  VERSION_LINE=$(grep -E "^[[:space:]]*version:[[:space:]]+[^[:space:]]" "$PUBSPEC" || true)
  if [ -z "$VERSION_LINE" ]; then
    # Try less strict regex to provide better error message
    if grep -q -E "^[[:space:]]*version:" "$PUBSPEC"; then
      error_exit "Version line found in pubspec.yaml but has invalid format. Expected 'version: X.Y.Z+N'"
    else
      error_exit "No version line found in pubspec.yaml"
    fi
  fi

  # Extract the whitespace between "version:" and the version value
  VERSION_WHITESPACE=$(echo "$VERSION_LINE" | sed -E 's/^([[:space:]]*version:)([[:space:]]+).*/\2/')
  debug "Version whitespace: '$VERSION_WHITESPACE'"

  # Enhanced version pattern matching with validation
  CURRENT_VERSION=$(echo "$VERSION_LINE" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true)
  if [ -z "$CURRENT_VERSION" ]; then
    error_exit "Invalid version format in pubspec.yaml. Expected X.Y.Z format (e.g., 1.2.3)"
  fi

  # Extract build number with better validation
  BUILD_PART=$(echo "$VERSION_LINE" | grep -oE '\+[^[:space:]]+' || echo "+0")
  if [[ "$BUILD_PART" =~ \+[0-9]+ ]]; then
    CURRENT_BUILD=$(echo "$BUILD_PART" | cut -c2-)
    debug "Extracted build number: $CURRENT_BUILD"
  else
    warning "Non-numeric build number found in pubspec.yaml: $BUILD_PART"
    warning "Defaulting to build number 0"
    CURRENT_BUILD=0
  fi

  info "Current version detected: ${CURRENT_VERSION}+${CURRENT_BUILD}"

  # Handle version argument
  if [ -z "$VERSION_ARG" ]; then
    info "No version argument provided. Auto-incrementing PATCH."
    IFS='.' read -r MAJOR MINOR PATCH <<<"$CURRENT_VERSION"
    PATCH=$((PATCH + 1))
    NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
  elif [ "$VERSION_ARG" = "major" ]; then
    IFS='.' read -r MAJOR MINOR PATCH <<<"$CURRENT_VERSION"
    MAJOR=$((MAJOR + 1))
    NEW_VERSION="${MAJOR}.0.0"
    info "Bumping MAJOR version."
  elif [ "$VERSION_ARG" = "minor" ]; then
    IFS='.' read -r MAJOR MINOR PATCH <<<"$CURRENT_VERSION"
    MINOR=$((MINOR + 1))
    NEW_VERSION="${MAJOR}.${MINOR}.0"
    info "Bumping MINOR version."
  elif [ "$VERSION_ARG" = "patch" ]; then
    IFS='.' read -r MAJOR MINOR PATCH <<<"$CURRENT_VERSION"
    PATCH=$((PATCH + 1))
    NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
    info "Bumping PATCH version."
  else
    # Validate custom version format
    if ! [[ "$VERSION_ARG" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      error_exit "Invalid version format. Expected X.Y.Z (e.g., 1.2.3) or 'major', 'minor', 'patch'"
    fi

    NEW_VERSION="$VERSION_ARG"
    if [ "$NEW_VERSION" = "$CURRENT_VERSION" ]; then
      warning "You provided the same version as current ($CURRENT_VERSION). Build number will still increment."
    fi
  fi

  # Handle build number
  if [ -n "$BUILD_ARG" ]; then
    if ! [[ "$BUILD_ARG" =~ ^[0-9]+$ ]]; then
      error_exit "Build number must be a positive integer, got: $BUILD_ARG"
    fi
    NEW_BUILD=$BUILD_ARG
    info "Using specified build number: $NEW_BUILD"
  else
    NEW_BUILD=$((CURRENT_BUILD + 1))
    info "Auto-incrementing build number to: $NEW_BUILD"
  fi

  # Validate against Flutter version format requirements
  if [ ${#NEW_VERSION} -gt 20 ]; then
    error_exit "Version string exceeds Flutter's maximum length"
  fi

  info "Updating to: $NEW_VERSION+$NEW_BUILD"

  # Update pubspec.yaml with preserved whitespace
  # Use local temp file for better portability across platforms
  if [ "$OS_TYPE" = "mac" ]; then
    sed -E "s/^([[:space:]]*version:)[[:space:]]+.*/\\1$VERSION_WHITESPACE$NEW_VERSION+$NEW_BUILD/" "$PUBSPEC" > "$TEMP_FILE" ||
      error_exit "Failed to update version with sed"
  else
    # For both Windows (with proper tools) and Unix
    sed -E "s/^([[:space:]]*version:)[[:space:]]+.*/\\1$VERSION_WHITESPACE$NEW_VERSION+$NEW_BUILD/" "$PUBSPEC" > "$TEMP_FILE" ||
      error_exit "Failed to update version with sed"
  fi

  # Check if the file was modified successfully before replacing the original
  if [ -s "$TEMP_FILE" ]; then
    # Verify that the temp file contains a valid version line
    if ! grep -q -E "^[[:space:]]*version:[[:space:]]+$NEW_VERSION\+$NEW_BUILD" "$TEMP_FILE"; then
      rm -f "$TEMP_FILE"
      error_exit "Failed to update version correctly in the temporary file."
    fi

    cp "$TEMP_FILE" "$PUBSPEC" || error_exit "Failed to update pubspec.yaml"
    rm -f "$TEMP_FILE"
  else
    rm -f "$TEMP_FILE"
    error_exit "Failed to generate a valid pubspec.yaml. The temporary file was empty."
  fi

  # Confirm update
  UPDATED_LINE=$(grep -E '^[[:space:]]*version:' "$PUBSPEC" || echo "")
  if [[ "$UPDATED_LINE" == *"$NEW_VERSION+$NEW_BUILD"* ]]; then
    echo ""
    echo -e "${GREEN}🎯 Version updated successfully!${NC}"
    echo -e "${GREEN}🔹 Old Version: $CURRENT_VERSION+$CURRENT_BUILD${NC}"
    echo -e "${GREEN}🔹 New Version: $NEW_VERSION+$NEW_BUILD${NC}"
  else
    # Restore backup if update failed
    cp "$BACKUP_FILE" "$PUBSPEC"
    error_exit "Failed to update pubspec.yaml correctly. Restored from backup."
  fi
}

# Git and GitHub integration
function handle_git {
  if ! command_exists git; then
    warning "Git is not installed or not in PATH. Skipping Git and GitHub operations."
    info "To use GitHub features, please install Git: https://git-scm.com/downloads"

    # Check if GitHub CLI is available
    if command_exists gh; then
      info "GitHub CLI is installed, which is great for GitHub integration."
    else
      info "To use GitHub repository creation, please install GitHub CLI: https://cli.github.com/"
    fi
    return 1
  fi

  section "Git Operations"

  # Check if this is a git repository
  if [ -d .git ]; then
    read -rp "💬 Do you want to commit version update to Git? (y/n): " CONFIRM
    case "$CONFIRM" in
      [Yy]* )
        if ! git add "$PUBSPEC"; then
          warning "Failed to add pubspec.yaml to Git."
          GIT_SUCCESS=false
        else
          if ! git commit -m "🚀 Bump version to $NEW_VERSION+$NEW_BUILD"; then
            warning "Git commit failed."
            GIT_SUCCESS=false
          else
            GIT_SUCCESS=true
            info "Version bump committed to Git."
          fi
        fi

        # Optional: Create a version tag (only if commit succeeded)
        if [ "$GIT_SUCCESS" = true ]; then
          read -rp "Do you want to create a git tag for this version? (y/n): " TAG_CONFIRM
          if [[ "$TAG_CONFIRM" =~ ^[Yy] ]]; then
            TAG_NAME="v$NEW_VERSION"

            # Check if tag already exists
            if git rev-parse "$TAG_NAME" &>/dev/null; then
              read -rp "Tag $TAG_NAME already exists. Overwrite? (y/n): " OVERWRITE_TAG
              if [[ "$OVERWRITE_TAG" =~ ^[Yy] ]]; then
                git tag -d "$TAG_NAME" &>/dev/null
                if git tag -a "$TAG_NAME" -m "Version $NEW_VERSION+$NEW_BUILD"; then
                  info "Created git tag: $TAG_NAME"
                  TAG_CREATED=true
                else
                  warning "Failed to create git tag."
                  TAG_CREATED=false
                fi
              else
                warning "Skipped tag creation."
                TAG_CREATED=false
              fi
            else
              if git tag -a "$TAG_NAME" -m "Version $NEW_VERSION+$NEW_BUILD"; then
                info "Created git tag: $TAG_NAME"
                TAG_CREATED=true
              else
                warning "Failed to create git tag."
                TAG_CREATED=false
              fi
            fi
          else
            TAG_CREATED=false
          fi
        fi

        # Handle GitHub remote operations
        if [ "$GIT_SUCCESS" = true ]; then
          # Check if remote exists
          if git remote get-url origin &>/dev/null; then
            read -rp "Do you want to push changes to GitHub? (y/n): " PUSH_CONFIRM
            if [[ "$PUSH_CONFIRM" =~ ^[Yy] ]]; then
              info "Pushing to GitHub..."
              current_branch=$(get_current_branch)
              info "Using branch: $current_branch"

              if git push origin "$current_branch"; then
                info "Changes pushed to GitHub successfully!"

                # Push tags if created
                if [ "$TAG_CREATED" = true ]; then
                  if git push origin "$TAG_NAME"; then
                    info "Tag pushed to GitHub successfully!"
                  else
                    warning "Failed to push tag to GitHub."
                  fi
                fi
              else
                warning "Failed to push to GitHub. Please check your connection and permissions."
              fi
            fi
          else
            read -rp "No remote repository found. Would you like to set up GitHub? (y/n): " SETUP_GITHUB
            if [[ "$SETUP_GITHUB" =~ ^[Yy] ]]; then
              setup_github

              # Offer to push if setup was successful
              if git remote get-url origin &>/dev/null; then
                read -rp "Push changes to GitHub now? (y/n): " PUSH_NOW
                if [[ "$PUSH_NOW" =~ ^[Yy] ]]; then
                  info "Pushing to GitHub..."
                  current_branch=$(get_current_branch)
                  info "Using branch: $current_branch"

                  if git push -u origin "$current_branch"; then
                    info "Changes pushed to GitHub successfully!"

                    # Push tags if created
                    if [ "$TAG_CREATED" = true ]; then
                      if git push origin "$TAG_NAME"; then
                        info "Tag pushed to GitHub successfully!"
                      else
                        warning "Failed to push tag to GitHub."
                      fi
                    fi
                  else
                    warning "Failed to push to GitHub. Please check your connection and permissions."
                  fi
                fi
              fi
            fi
          fi
        fi
        ;;
      * )
        warning "Skipped Git commit."
        ;;
    esac
  else
    read -rp "Not a Git repository. Would you like to initialize one? (y/n): " INIT_GIT
    if [[ "$INIT_GIT" =~ ^[Yy] ]]; then
      # Initialize Git repository
      if git init; then
        info "Git repository initialized."

        # Initial commit
        if git add "$PUBSPEC" && git commit -m "🚀 Initial commit with version $NEW_VERSION+$NEW_BUILD"; then
          info "Initial commit created."

          # Offer GitHub setup
          read -rp "Would you like to set up GitHub for this project? (y/n): " SETUP_GITHUB
          if [[ "$SETUP_GITHUB" =~ ^[Yy] ]]; then
            setup_github

            # Offer to push if setup was successful
            if git remote get-url origin &>/dev/null; then
              read -rp "Push changes to GitHub now? (y/n): " PUSH_NOW
              if [[ "$PUSH_NOW" =~ ^[Yy] ]]; then
                info "Pushing to GitHub..."
                current_branch=$(get_current_branch)
                info "Using branch: $current_branch"

                if git push -u origin "$current_branch"; then
                  info "Changes pushed to GitHub successfully!"
                else
                  warning "Failed to push to GitHub. Please check your connection and permissions."
                fi
              fi
            fi
          fi
        else
          warning "Failed to create initial commit."
        fi
      else
        warning "Failed to initialize Git repository."
      fi
    fi
  fi
}

# Check OS type and available tools
function detect_os {
  if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win"* ]]; then
    OS_TYPE="windows"
    warning "Running on Windows environment."

    # Check for required tools
    if ! command -v sed &>/dev/null || ! command -v grep &>/dev/null; then
      error_exit "This script requires Unix tools (sed, grep) to run on Windows.
Please install Git Bash, MinGW, WSL, or similar environment.
Alternatively, use the PowerShell version of this script."
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="mac"
    debug "Running on macOS."
  else
    OS_TYPE="unix"
    debug "Running on Unix/Linux."
  fi
}

# Set up trap for both normal exit and interrupts
trap cleanup EXIT
trap 'echo -e "${YELLOW}Script interrupted. Cleaning up...${NC}"; cleanup; exit 1' INT TERM

# Show banner
function show_banner {
  echo -e "${CYAN}"
  echo "================================================"
  echo "  Flutter Version Bump & Build Script v2.0.0"
  echo "================================================"
  echo -e "${NC}"
}

# Main function
function main() {
  show_banner

  # Parse command line arguments
  parse_arguments "$@"

  # Show help if requested
  if [[ "$1" == "--help" ]]; then
    show_help
    exit 0
  fi

  # Detect OS
  detect_os

  # Check for pubspec.yaml
  [ -f "$PUBSPEC" ] || error_exit "pubspec.yaml not found in current directory."

  # Perform version bump if not in build-only mode
  if [ "$VERSION_BUMP" = true ]; then
    perform_version_bump

    # Handle Git operations
    handle_git
  else
    # In build-only mode, just extract current version for reference
    VERSION_LINE=$(grep -E "^[[:space:]]*version:" "$PUBSPEC" | head -1)
    if [ -n "$VERSION_LINE" ]; then
      CURRENT_VERSION=$(echo "$VERSION_LINE" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "Unknown")
      CURRENT_BUILD=$(echo "$VERSION_LINE" | grep -oE '\+[0-9]+' | cut -c2- || echo "Unknown")
      info "Current version: ${CURRENT_VERSION}+${CURRENT_BUILD} (not changing in build-only mode)"
      NEW_VERSION=$CURRENT_VERSION
      NEW_BUILD=$CURRENT_BUILD
    else
      warning "Could not detect current version in build-only mode"
    fi
  fi

  # Build Flutter app unless specifically skipped
  if [ "$NO_BUILD" != true ]; then
    build_flutter_app
  fi

  section "Complete"
  info "✅ All operations completed successfully!"
}

# Run main function with all arguments
main "$@"