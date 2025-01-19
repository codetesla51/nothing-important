#!/bin/bash

# Check if start and end dates are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 start_date end_date"
    echo "Date format: YYYY-MM-DD"
    exit 1
fi

start_date=$(date -d "$1" +%s)
end_date=$(date -d "$2" +%s)

# Initialize git if not already initialized
if [ ! -d .git ]; then
    git init
    echo "Git repository initialized"
fi

# Create a dummy file if it doesn't exist
if [ ! -f commits.txt ]; then
    touch commits.txt
fi

# Add remote if not exists (uncomment and modify if needed)
# if ! git remote | grep -q "origin"; then
#     git remote add origin YOUR_REMOTE_URL
# fi

# Function to generate random commit messages
generate_commit_message() {
    messages=(
        "Update documentation"
        "Fix bug in main logic"
        "Add new feature"
        "Refactor code"
        "Optimize performance"
        "Update dependencies"
        "Fix typos"
        "Clean up code"
        "Improve error handling"
        "Add unit tests"
    )
    echo "${messages[$RANDOM % ${#messages[@]}]}"
}

# Iterate through each day in the date range
current_date=$start_date
while [ $current_date -le $end_date ]; do
    # 70% chance to make commits on this day
    if [ $((RANDOM % 100)) -lt 70 ]; then
        # Random number of commits for this day (1-5)
        num_commits=$((RANDOM % 5 + 1))
        
        for ((i=1; i<=num_commits; i++)); do
            # Generate random time for this day
            hour=$((RANDOM % 14 + 8))  # Between 8 AM and 10 PM
            minute=$((RANDOM % 60))
            second=$((RANDOM % 60))
            
            # Format the date string
            commit_date=$(date -d "@$current_date" "+%Y-%m-%d")
            GIT_AUTHOR_DATE="$commit_date $hour:$minute:$second"
            GIT_COMMITTER_DATE="$commit_date $hour:$minute:$second"
            
            # Make random changes to the file
            echo "Update $(date +%s)${RANDOM}" >> commits.txt
            
            # Stage and commit
            export GIT_AUTHOR_DATE
            export GIT_COMMITTER_DATE
            git add commits.txt
            git commit -m "$(generate_commit_message)" --date="$GIT_AUTHOR_DATE"
            
            echo "Created commit on $GIT_AUTHOR_DATE"
        done
    fi
    
    # Move to next day
    current_date=$((current_date + 86400))  # Add 24 hours in seconds
done

echo "Commit generation completed!"
# Uncomment the following line if you want to push to remote
# git push origin master