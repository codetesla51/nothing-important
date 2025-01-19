#!/bin/bash

#  ██████╗ ██████╗ ███╗   ███╗███╗   ███╗██╗██╗  ██╗
# ██╔════╝██╔═══██╗████╗ ████║████╗ ████║██║╚██╗██╔╝
# ██║     ██║   ██║██╔████╔██║██╔████╔██║██║ ╚███╔╝ 
# ██║     ██║   ██║██║╚██╔╝██║██║╚██╔╝██║██║ ██╔██╗ 
# ╚██████╗╚██████╔╝██║ ╚═╝ ██║██║ ╚═╝ ██║██║██╔╝ ██╗
#  ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═╝
#
# Author: Uthman Dev
# GitHub: https://github.com/codetesla51
# Script Name: Commix - Enhanced GitHub Auto Commit Script
# Version: 2.0

# Color definitions
declare -A colors=(
    ["INFO"]=$'\033[1;34m'      # Blue
    ["SUCCESS"]=$'\033[1;32m'    # Green
    ["WARNING"]=$'\033[1;33m'    # Yellow
    ["ERROR"]=$'\033[1;31m'      # Red
    ["NC"]=$'\033[0m'           # No Color
)

# Function to prompt for user confirmation
warn_user() {
    while true; do
        read -p "$1 (y/n): " answer
        case $answer in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) print_message "WARNING" "Please answer yes or no." ;;
        esac
    done
}

# Array of realistic commit messages
commit_messages=(
    "Update documentation and add examples"
    "Fix edge case in main logic"
    "Optimize performance for large datasets"
    "Implement error handling"
    "Add unit tests for core functions"
    "Refactor code for better maintainability"
    "Update dependencies to latest versions"
    "Fix typos in documentation"
    "Add logging functionality"
    "Improve error messages"
    "Implement feature request #"
    "Fix bug report #"
    "Clean up deprecated code"
    "Enhance security measures"
    "Add input validation"
)

# Function to print colored messages
print_message() {
    local type=$1
    local message=$2
    echo -e "${colors[$type]}$message${colors[NC]}"
}

# Function to check git configuration
check_git_config() {
    if ! git config user.name > /dev/null || ! git config user.email > /dev/null; then
        print_message "ERROR" "Git user name or email not configured!"
        print_message "INFO" "Please configure git first:"
        print_message "INFO" "git config --global user.name 'Your Name'"
        print_message "INFO" "git config --global user.email 'your.email@example.com'"
        exit 1
    fi
}

# Function to get random commit message
get_random_commit_message() {
    local random_index=$((RANDOM % ${#commit_messages[@]}))
    local message=${commit_messages[$random_index]}
    echo "$message $((RANDOM % 1000))"
}

# Display banner
display_banner() {
    clear
    print_message "SUCCESS" "
 ██████╗ ██████╗ ███╗   ███╗███╗   ███╗██╗██╗  ██╗
██╔════╝██╔═══██╗████╗ ████║████╗ ████║██║╚██╗██╔╝
██║     ██║   ██║██╔████╔██║██╔████╔██║██║ ╚███╔╝ 
██║     ██║   ██║██║╚██╔╝██║██║╚██╔╝██║██║ ██╔██╗ 
╚██████╗╚██████╔╝██║ ╚═╝ ██║██║ ╚═╝ ██║██║██╔╝ ██╗
 ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═╝
    "
    sleep 1
}

# Main commit function
auto_commit_function() {
    local start_date=$1
    local days=$2
    local max_commits=$3

    # Initialize repository if needed
    if [ ! -d .git ]; then
        print_message "INFO" "Initializing new Git repository..."
        git init > /dev/null 2>&1
    fi

    # Create or update dummy file
    local file_name="project_data.txt"
    [ ! -f "$file_name" ] && touch "$file_name"

    # Main commit loop
    for ((day=0; day<days; day++)); do
        # Random decision to commit on this day (70% chance)
        if [ $((RANDOM % 10)) -lt 7 ]; then
            current_date=$(date -d "$start_date + $day days" +%Y-%m-%dT%H:%M:%S)
            num_commits=$((RANDOM % max_commits + 1))
            
            print_message "INFO" "Creating $num_commits commits for $current_date"
            
            for ((i=1; i<=num_commits; i++)); do
                # Add random content
                echo "Update $(date +%s)-$i" >> "$file_name"
                
                # Stage changes
                git add "$file_name" > /dev/null 2>&1
                
                # Commit with random message
                commit_msg=$(get_random_commit_message)
                export GIT_AUTHOR_DATE="$current_date"
                export GIT_COMMITTER_DATE="$current_date"
                git commit -m "$commit_msg" > /dev/null 2>&1
                
                print_message "SUCCESS" "✓ Commit added: $commit_msg"
            done
        else
            print_message "WARNING" "Skipping commits for day $((day + 1))"
        fi
    done

    # Push changes
    print_message "INFO" "Attempting to push commits..."
    if git push origin main 2>/dev/null; then
        print_message "SUCCESS" "Successfully pushed all commits!"
    else
        print_message "ERROR" "Failed to push commits. Please check your remote configuration and network connection."
    fi
}

# Main execution
display_banner

print_message "INFO" "Welcome to Commix - Enhanced GitHub Auto Commit Script"
print_message "WARNING" "Use this script responsibly to avoid any GitHub account restrictions."

# Check git configuration
check_git_config

# Prompt for configuration
read -p "Enter start date (YYYY-MM-DD) [default: 2023-01-01]: " start_date
start_date=${start_date:-2023-01-01}

read -p "Enter number of days to process [default: 30]: " days
days=${days:-30}

read -p "Enter maximum commits per day [default: 10]: " max_commits
max_commits=${max_commits:-10}

if warn_user "Do you want to proceed with these settings?"; then
    auto_commit_function "$start_date" "$days" "$max_commits"
else
    print_message "WARNING" "Script execution cancelled."
    exit 0
fi