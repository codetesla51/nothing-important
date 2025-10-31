#!/bin/bash

declare -A colors=(
    ["INFO"]=$'\033[1;34m'
    ["SUCCESS"]=$'\033[1;32m'
    ["WARNING"]=$'\033[1;33m'
    ["ERROR"]=$'\033[1;31m'
    ["NC"]=$'\033[0m'
)

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

print_message() {
    local type=$1
    local message=$2
    echo -e "${colors[$type]}$message${colors[NC]}"
}

check_git_config() {
    if ! git config user.name > /dev/null || ! git config user.email > /dev/null; then
        print_message "ERROR" "Git user not configured!"
        print_message "INFO" "Run: git config --global user.name 'Your Name'"
        print_message "INFO" "Run: git config --global user.email 'your.email@example.com'"
        exit 1
    fi
}

get_random_commit_message() {
    local random_index=$((RANDOM % ${#commit_messages[@]}))
    echo "${commit_messages[$random_index]} $((RANDOM % 1000))"
}

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
}

auto_commit_function() {
    local start_date=$1
    local days=$2
    local max_commits=$3
    local file_name="project_data.txt"
    
    touch "$file_name"

    for ((day=0; day<days; day++)); do
        if [ $((RANDOM % 10)) -lt 7 ]; then
            current_date=$(date -d "$start_date + $day days" +%Y-%m-%dT%H:%M:%S 2>/dev/null || date -v+"$day"d -j -f "%Y-%m-%d" "$start_date" +%Y-%m-%dT%H:%M:%S 2>/dev/null)
            
            if [ -z "$current_date" ]; then
                print_message "ERROR" "Invalid date format. Use YYYY-MM-DD"
                exit 1
            fi
            
            num_commits=$((RANDOM % max_commits + 1))

            print_message "INFO" "Day $((day + 1)): Creating $num_commits commits"

            for ((i=1; i<=num_commits; i++)); do
                echo "Update $(date +%s)-$i" >> "$file_name"
                git add "$file_name" > /dev/null 2>&1
                
                commit_msg=$(get_random_commit_message)
                export GIT_AUTHOR_DATE="$current_date"
                export GIT_COMMITTER_DATE="$current_date"
                git commit -m "$commit_msg" > /dev/null 2>&1

                print_message "SUCCESS" "✓ $commit_msg"
            done
        else
            print_message "WARNING" "Day $((day + 1)): Skipping (no commits)"
        fi
    done

    print_message "INFO" "Pushing commits..."
    
    if ! git remote get-url origin &> /dev/null; then
        git remote add origin "https://github.com/$github_user/$remote_repo_name.git" 2>/dev/null || {
            print_message "ERROR" "Failed to add remote!"
            exit 1
        }
    fi
    
    if git push -u origin main 2>/dev/null || git push -u origin master 2>/dev/null; then
        print_message "SUCCESS" "All commits pushed successfully!"
        print_message "SUCCESS" "Check: https://github.com/$github_user/$remote_repo_name"
    else
        print_message "ERROR" "Push failed!"
        print_message "WARNING" "Make sure you created a NEW, EMPTY repository (no README, no .gitignore)"
        print_message "INFO" "Repository should be at: https://github.com/$github_user/$remote_repo_name"
        exit 1
    fi
}

main() {
    display_banner
    check_git_config

    print_message "INFO" "Welcome to Commix - GitHub Auto Commit Tool"
    print_message "WARNING" "Use responsibly!"
    echo

    if [ -d .git ]; then
        print_message "INFO" "Detected existing git repository in current directory"
        read -p "Use this repository? (y/n): " use_current
        if [[ $use_current =~ ^[Yy]$ ]]; then
            print_message "SUCCESS" "Using current repository"
        else
            read -p "Enter new directory name: " repo_name
            if [ -z "$repo_name" ]; then
                print_message "ERROR" "Directory name required!"
                exit 1
            fi
            if [ -d "$repo_name" ]; then
                print_message "ERROR" "Directory $repo_name already exists!"
                exit 1
            fi
            mkdir -p "$repo_name" || {
                print_message "ERROR" "Failed to create directory!"
                exit 1
            }
            cd "$repo_name" || exit 1
            git init > /dev/null 2>&1 || {
                print_message "ERROR" "Failed to initialize git!"
                exit 1
            }
            git branch -M main > /dev/null 2>&1
            print_message "SUCCESS" "Initialized repository in $repo_name/"
        fi
    else
        read -p "Use current directory as repository? (y/n): " use_current_dir
        if [[ $use_current_dir =~ ^[Yy]$ ]]; then
            print_message "INFO" "Using current directory"
            git init > /dev/null 2>&1 || {
                print_message "ERROR" "Failed to initialize git!"
                exit 1
            }
            git branch -M main > /dev/null 2>&1
            print_message "SUCCESS" "Initialized repository in current directory"
        else
            read -p "Enter directory name: " repo_name
            if [ -z "$repo_name" ]; then
                print_message "ERROR" "Directory name required!"
                exit 1
            fi
            if [ -d "$repo_name" ]; then
                print_message "ERROR" "Directory $repo_name already exists!"
                exit 1
            fi
            mkdir -p "$repo_name" || {
                print_message "ERROR" "Failed to create directory!"
                exit 1
            }
            cd "$repo_name" || exit 1
            git init > /dev/null 2>&1 || {
                print_message "ERROR" "Failed to initialize git!"
                exit 1
            }
            git branch -M main > /dev/null 2>&1
            print_message "SUCCESS" "Initialized repository in $repo_name/"
        fi
    fi

    read -p "GitHub username: " github_user
    if [ -z "$github_user" ]; then
        print_message "ERROR" "GitHub username required!"
        exit 1
    fi

    read -p "GitHub repository name: " remote_repo_name
    if [ -z "$remote_repo_name" ]; then
        print_message "ERROR" "GitHub repository name required!"
        exit 1
    fi

    print_message "WARNING" "IMPORTANT: Create a NEW, EMPTY repository on GitHub:"
    print_message "INFO" "1. Go to: https://github.com/new"
    print_message "INFO" "2. Repository name: $remote_repo_name"
    print_message "INFO" "3. DO NOT initialize with README, .gitignore, or license"
    print_message "INFO" "4. Keep it completely empty"
    echo
    read -p "Empty repository created? (y/n): " repo_exists
    if [[ ! $repo_exists =~ ^[Yy]$ ]]; then
        print_message "WARNING" "Please create an empty repository first, then run this script again"
        exit 0
    fi

    read -p "Start date (YYYY-MM-DD) [2023-01-01]: " start_date
    start_date=${start_date:-2023-01-01}

    read -p "Number of days [30]: " days
    days=${days:-30}

    read -p "Max commits per day [10]: " max_commits
    max_commits=${max_commits:-10}

    echo
    print_message "INFO" "Local directory: $(basename "$PWD")"
    print_message "INFO" "GitHub repo: https://github.com/$github_user/$remote_repo_name"
    print_message "INFO" "Period: $start_date for $days days"
    print_message "INFO" "Max commits/day: $max_commits"
    echo

    read -p "Proceed? (y/n): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        print_message "WARNING" "Cancelled"
        exit 0
    fi

    auto_commit_function "$start_date" "$days" "$max_commits"
}

main