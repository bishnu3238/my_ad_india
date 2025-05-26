# Flutter Version Bump & Build Script

This is a comprehensive Bash script designed to automate the process of updating your Flutter project's version and build numbers in `pubspec.yaml`, optionally handling Git commits, tags, pushes, and triggering various Flutter build commands.

It includes robust error handling, backups, and interactive prompts for various steps like Git operations and build choices.

## Features

*   **Version Bumping:** Automatically increments the patch version by default, or allows bumping major, minor, or setting a specific version (X.Y.Z).
*   **Build Number Increment/Setting:** Automatically increments the build number, or allows setting a specific integer build number.
*   **`pubspec.yaml` Update:** Updates the `version: X.Y.Z+N` line in your `pubspec.yaml`, preserving original formatting whitespace.
*   **Automatic Backup:** Creates a backup of `pubspec.yaml` before modifying it, with automatic restore on error or script interruption.
*   **Git Integration:**
    *   Detects if it's a Git repository.
    *   Prompts to add and commit the `pubspec.yaml` changes.
    *   Prompts to create a Git tag (vX.Y.Z).
    *   Prompts to push commits and tags to the configured remote origin.
    *   Offers to initialize a Git repository if none exists.
*   **GitHub Integration (Requires GitHub CLI `gh`):**
    *   If a remote origin is not configured, it can optionally guide you through creating a new GitHub repository for your project using the `gh` CLI.
    *   Pushes to the new GitHub repository if setup is successful.
*   **Flutter Build:**
    *   After version/Git operations, it can optionally prompt you to choose a build target (APK, App Bundle, iOS, Web).
    *   Runs the corresponding `flutter build` command.
    *   Offers to rename APK/AAB outputs to include the version and build number for easier management.
*   **Command Line Options:** Supports options for debug output, build-only mode, and skipping the build step.
*   **Interactive Prompts:** Guides you through steps like committing, tagging, pushing, and building with 'y/n' confirmations.

## Prerequisites

Before running this script, ensure you have the following installed and configured:

1.  **Bash:** This is a Bash script. It's the default shell on macOS and most Linux distributions.
    *   **On Windows:** You need an environment that provides Bash and standard Unix command-line tools (`sed`, `grep`, `cp`, `rm`, `basename`, `head`, `cut`, `git`, `command`, `read`, `set`, `trap`, `cat`, `echo`, `expr`, `sort`, `uniq`).
        *   **Recommended:** [Windows Subsystem for Linux 2 (WSL2)](https://docs.microsoft.com/en-us/windows/wsl/install) (Install Ubuntu or another distribution). Run the script from within your WSL terminal.
        *   **Alternative:** [Git Bash](https://gitforwindows.org/) (comes with Git for Windows), [MinGW-w64](http://mingw-w64.org/doku.php), or [Cygwin](https://www.cygwin.com/). Run the script from their respective terminals.
2.  **Git:** [https://git-scm.com/downloads](https://git-scm.com/downloads) - Required for all Git/GitHub features.
3.  **Flutter SDK:** [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install) - Required for the build steps. Ensure `flutter` command is in your system's PATH.
4.  **GitHub CLI (optional but recommended):** [https://cli.github.com/](https://cli.github.com/) - Required for the automatic GitHub repository creation feature (`gh`). If you don't install it, you can still use the script, but you'll need to manually set up your GitHub remote if you don't have one. You also need to be authenticated (`gh auth login`).

## Installation

1.  Save the script code to a file named `version_bump.sh` in the root directory of your Flutter project (the same directory as `pubspec.yaml`).
2.  Make the script executable (on Linux, macOS, or Git Bash/WSL on Windows):
    ```bash
    chmod +x version_bump.sh
    ```

## Usage

Run the script from the root directory of your Flutter project:

```bash
./version_bump.sh [options] [version] [build-number]


Arguments
You can provide optional positional arguments to control the version and build number:
[version]: How to update the version part (X.Y.Z).
If omitted: Increments the patch version (e.g., 1.2.3 becomes 1.2.4).
major: Increments the major version and sets minor/patch to 0 (e.g., 1.2.3 becomes 2.0.0).
minor: Increments the minor version and sets patch to 0 (e.g., 1.2.3 becomes 1.3.0).
patch: Increments the patch version (same as omitting the argument).
X.Y.Z: Sets a specific version string (e.g., 1.5.0). Must follow the number.number.number format.
[build-number]: How to update the build number part (+N).
If omitted: Increments the current build number (e.g., 1.2.3+42 becomes 1.2.3+43). If the pubspec.yaml doesn't have a build number, it defaults to 0 and increments to 1.
N: Sets a specific integer build number (e.g., 42). Must be a positive integer.
Arguments can be given in any order after options.
Options
-d, --debug: Enables verbose debug output during script execution.
--build-only: Skips the version bumping and Git operations. Only performs the build step based on the current version/build number in pubspec.yaml.
--no-build: Skips the build step after performing version bumping and Git operations.
--help: Displays the help message and exits.
```


[//]: # (EXAMPLE)

# Automatically increments patch version and build number (e.g., 1.2.3+42 -> 1.2.4+43)
./version_bump.sh

# Increments minor version and sets build number to 1 (e.g., 1.2.3+42 -> 1.3.0+1)
./version_bump.sh minor 1

# Sets version to 2.0.0 and auto-increments build number (e.g., 1.5.0+10 -> 2.0.0+11)
./version_bump.sh 2.0.0

# Sets version to 1.2.3 and build number to 99
./version_bump.sh 1.2.3 99

# Bumps patch version, but skips the build step
./version_bump.sh patch --no-build

# Only builds the app using the current version in pubspec.yaml (skips version bump and git)
./version_bump.sh --build-only

# Shows help message
./version_bump.sh --help




Workflow
When you run the script, it typically performs the following steps (depending on options and your responses to prompts):
Displays a banner.
Parses command-line arguments and options.
Detects the operating system and checks for required tools (sed, grep on Windows).
Checks if pubspec.yaml exists.
[If not --build-only]:
Creates a backup of pubspec.yaml.
Reads the current version line from pubspec.yaml, extracts the version (X.Y.Z) and build number (+N).
Validates the current version format.
Calculates the new version and build number based on arguments or defaults.
Updates the version line in pubspec.yaml with the new value, preserving original spacing, using sed.
Validates the update by checking the modified file.
[If Git is installed]:
Checks if it's a Git repository and if a remote origin exists.
If it's a new Git repo without a remote, offers to initialize it and then use gh to create and link a GitHub repository.
Prompts you to confirm committing the pubspec.yaml change.
Prompts you to confirm creating a Git tag (vX.Y.Z).
Prompts you to confirm pushing the commit(s) and tag(s) to the remote origin.
[If not --no-build]:
Prompts you to select a Flutter build target (APK, AAB, iOS, Web) or skip the build.
Runs the selected flutter build command.
If building APK or AAB, shows the output path and offers to rename the file to include the new version and build number.
Prints a completion message.
Automatically cleans up temporary files (backup file is removed on successful completion or if cleanup is triggered).
Notes and Troubleshooting
Windows Users: You absolutely must run this script in an environment that provides Bash and standard Unix tools like sed and grep. Git Bash, MinGW, or WSL2 are recommended. Running it directly in Command Prompt or PowerShell will not work out-of-the-box.
Permissions: Ensure the script has execute permissions (chmod +x).
Backup: A backup of pubspec.yaml is created as pubspec.yaml.script_backup. It should be automatically cleaned up. If the script crashes unexpectedly, you might find this file and can use it to manually restore.
GitHub CLI: The script requires gh to be installed and you to be logged in (gh auth login) to create a new GitHub repository. It gracefully falls back if gh is not available or authenticated but won't be able to create the remote repo automatically.
Git Remote: The script is designed to work best with a remote named origin. If your remote has a different name, you might need to adjust the Git push commands or manually push after the script finishes.
Pubspec Format: The script expects the version line in pubspec.yaml to be in the format version: X.Y.Z+N or version: X.Y.Z. It is robust to varying whitespace after version:.
Error Handling: set -e ensures the script stops immediately on any command failure. The trap cleanup EXIT INT TERM ensures temporary files are removed even if the script is interrupted.
Build Modes: When building APK, you can specify release, debug, or profile. App Bundle (aab) and iOS builds are typically done in release mode for distribution, but the script allows options. iOS build only works on macOS.
This script is a powerful tool for streamlining your Flutter release process. Customize it further if needed to fit your specific workflow!





