#!/bin/bash

# GitHub Commit Art Generator
# Creates custom patterns in your GitHub contribution graph

set -e

# Configuration
REPO_NAME="commit-art"
COMMIT_FILE="art.txt"
COMMITS_PER_DAY=10  # Number of commits per active day (affects intensity)

# Color codes for terminal preview
GREEN='\033[0;32m'
DARK_GREEN='\033[1;32m'
RESET='\033[0m'

# Predefined patterns (52 weeks x 7 days)
declare -A PATTERNS

# Letter patterns (7x5 grid, scaled to fit GitHub's weekly view)
PATTERNS[A]="
  ███  
 █   █ 
 █████ 
 █   █ 
 █   █ 
"

PATTERNS[B]="
 ████  
 █   █ 
 ████  
 █   █ 
 ████  
"

PATTERNS[C]="
  ███  
 █   █ 
 █     
 █   █ 
  ███  
"

PATTERNS[D]="
 ████  
 █   █ 
 █   █ 
 █   █ 
 ████  
"

PATTERNS[E]="
 █████ 
 █     
 ████  
 █     
 █████ 
"

PATTERNS[F]="
 █████ 
 █     
 ████  
 █     
 █     
"

PATTERNS[G]="
  ███  
 █     
 █ ███ 
 █   █ 
  ███  
"

PATTERNS[H]="
 █   █ 
 █   █ 
 █████ 
 █   █ 
 █   █ 
"

PATTERNS[I]="
 █████ 
   █   
   █   
   █   
 █████ 
"

PATTERNS[L]="
 █     
 █     
 █     
 █     
 █████ 
"

PATTERNS[O]="
  ███  
 █   █ 
 █   █ 
 █   █ 
  ███  
"

PATTERNS[V]="
 █   █ 
 █   █ 
 █   █ 
  █ █  
   █   
"

PATTERNS[HEART]="
  █ █  
 █████ 
 █████ 
  ███  
   █   
"

PATTERNS[SMILE]="
  ███  
 █ █ █ 
 █   █ 
 █ █ █ 
  ███  
"

# Function to display available patterns
show_patterns() {
    echo "Available patterns:"
    for pattern in "${!PATTERNS[@]}"; do
        echo "  - $pattern"
    done
    echo ""
    echo "You can also create custom patterns using the custom option."
}

# Function to convert pattern string to 2D array
pattern_to_array() {
    local pattern="$1"
    local -n arr=$2
    local row=0
    
    # Clear array
    unset arr
    declare -gA arr
    
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            for ((col=0; col<${#line}; col++)); do
                char="${line:$col:1}"
                if [[ "$char" == "█" || "$char" == "#" || "$char" == "*" ]]; then
                    arr["$row,$col"]=1
                else
                    arr["$row,$col"]=0
                fi
            done
            ((row++))
        fi
    done <<< "$pattern"
    
    echo $row  # Return number of rows
}

# Function to preview pattern in terminal
preview_pattern() {
    local pattern="$1"
    local title="$2"
    
    echo "Preview of '$title':"
    echo "----------------------------------------"
    
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            local colored_line=""
            for ((i=0; i<${#line}; i++)); do
                char="${line:$i:1}"
                if [[ "$char" == "█" || "$char" == "#" || "$char" == "*" ]]; then
                    colored_line+="${DARK_GREEN}${char}${RESET}"
                elif [[ "$char" == " " ]]; then
                    colored_line+=" "
                else
                    colored_line+="${char}"
                fi
            done
            echo -e "$colored_line"
        fi
    done <<< "$pattern"
    
    echo "----------------------------------------"
    echo ""
}

# Function to get date string for commits (YYYY-MM-DD format)
get_date_for_commit() {
    local weeks_ago=$1
    local day_of_week=$2  # 0=Sunday, 1=Monday, ..., 6=Saturday
    
    # Get the date for the Sunday of the target week
    local sunday_date=$(date -d "$(date +%Y-%m-%d) - $weeks_ago weeks" +%Y-%m-%d)
    local sunday_epoch=$(date -d "$sunday_date" +%s)
    
    # Add days to get to the target day of week
    local target_epoch=$((sunday_epoch + day_of_week * 86400))
    date -d "@$target_epoch" +%Y-%m-%d
}

# Function to make commits for a specific date
make_commits_for_date() {
    local commit_date=$1
    local intensity=$2  # 0=none, 1=light, 2=medium, 3=heavy
    
    if [[ $intensity -eq 0 ]]; then
        return
    fi
    
    local num_commits=$((intensity * COMMITS_PER_DAY / 3))
    
    for ((i=1; i<=num_commits; i++)); do
        echo "Commit $i on $commit_date" >> "$COMMIT_FILE"
        git add "$COMMIT_FILE"
        
        # Set commit date and author date
        GIT_AUTHOR_DATE="$commit_date 12:00:00" \
        GIT_COMMITTER_DATE="$commit_date 12:00:00" \
        git commit -m "Art commit $i for $commit_date" --quiet
    done
}

# Function to create repository and generate commits
generate_commit_art() {
    local pattern="$1"
    local title="$2"
    
    echo "Creating commit art for: $title"
    echo "This will create a new repository called '$REPO_NAME'"
    echo ""
    
    # Create repository
    if [[ -d "$REPO_NAME" ]]; then
        echo "Warning: Directory '$REPO_NAME' already exists!"
        read -p "Do you want to remove it and continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Cancelled."
            return 1
        fi
        rm -rf "$REPO_NAME"
    fi
    
    mkdir "$REPO_NAME"
    cd "$REPO_NAME"
    
    git init --quiet
    git config user.email "art@example.com"
    git config user.name "Art Generator"
    
    # Create initial file
    echo "# Commit Art: $title" > "$COMMIT_FILE"
    echo "Generated on $(date)" >> "$COMMIT_FILE"
    
    # Convert pattern to array
    local -A pattern_array
    local num_rows=$(pattern_to_array "$pattern" pattern_array)
    
    # Generate commits (GitHub shows last 52 weeks)
    local weeks_to_generate=52
    local start_week=$((weeks_to_generate - 1))
    
    echo "Generating commits..."
    
    for ((week=0; week<weeks_to_generate; week++)); do
        for ((day=0; day<7; day++)); do
            local weeks_ago=$((start_week - week))
            local commit_date=$(get_date_for_commit $weeks_ago $day)
            
            # Calculate pattern position
            local pattern_col=$((week * 7 / weeks_to_generate * 7))  # Scale to pattern width
            local pattern_row=$((day * num_rows / 7))  # Scale to pattern height
            
            # Ensure we don't go out of bounds
            if [[ $pattern_row -ge $num_rows ]]; then
                pattern_row=$((num_rows - 1))
            fi
            
            local intensity=0
            if [[ -n "${pattern_array[$pattern_row,$pattern_col]}" ]]; then
                intensity=${pattern_array[$pattern_row,$pattern_col]}
                if [[ $intensity -eq 1 ]]; then
                    intensity=3  # Max intensity for active pixels
                fi
            fi
            
            make_commits_for_date "$commit_date" $intensity
        done
        
        # Progress indicator
        local progress=$((week * 100 / weeks_to_generate))
        echo -ne "\rProgress: $progress%"
    done
    
    echo -e "\nCommit art generated successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Create a new repository on GitHub called '$REPO_NAME'"
    echo "2. Push this repository:"
    echo "   git remote add origin https://github.com/YOUR_USERNAME/$REPO_NAME.git"
    echo "   git branch -M main"
    echo "   git push -u origin main"
    echo ""
    echo "3. Wait a few minutes, then check your GitHub profile!"
    echo "   The art will appear in your contribution graph."
    
    cd ..
}

# Function to create custom pattern interactively
create_custom_pattern() {
    echo "Create a custom pattern (max 7 rows, recommended width: 10-15 characters)"
    echo "Use '#', '*', or '█' for active pixels, spaces or '.' for inactive"
    echo "Enter each row, press Enter twice when done:"
    echo ""
    
    local custom_pattern=""
    local line_count=0
    
    while true; do
        if [[ $line_count -ge 7 ]]; then
            echo "Maximum 7 rows reached."
            break
        fi
        
        read -r line
        if [[ -z "$line" ]]; then
            if [[ -n "$custom_pattern" ]]; then
                break
            fi
        else
            custom_pattern+="$line"$'\n'
            ((line_count++))
        fi
    done
    
    if [[ -z "$custom_pattern" ]]; then
        echo "No pattern entered."
        return 1
    fi
    
    preview_pattern "$custom_pattern" "Custom Pattern"
    
    read -p "Use this pattern? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        generate_commit_art "$custom_pattern" "Custom Pattern"
    fi
}

# Main script
main() {
    echo "🎨 GitHub Commit Art Generator"
    echo "==============================="
    echo ""
    
    case "${1:-}" in
        "list"|"patterns")
            show_patterns
            ;;
        "preview")
            if [[ -z "${2:-}" ]]; then
                echo "Usage: $0 preview PATTERN_NAME"
                echo ""
                show_patterns
                exit 1
            fi
            
            local pattern_name="${2^^}"  # Convert to uppercase
            if [[ -n "${PATTERNS[$pattern_name]}" ]]; then
                preview_pattern "${PATTERNS[$pattern_name]}" "$pattern_name"
            else
                echo "Pattern '$2' not found."
                echo ""
                show_patterns
                exit 1
            fi
            ;;
        "generate")
            if [[ -z "${2:-}" ]]; then
                echo "Usage: $0 generate PATTERN_NAME"
                echo "   or: $0 generate custom"
                echo ""
                show_patterns
                exit 1
            fi
            
            if [[ "${2,,}" == "custom" ]]; then
                create_custom_pattern
            else
                local pattern_name="${2^^}"
                if [[ -n "${PATTERNS[$pattern_name]}" ]]; then
                    preview_pattern "${PATTERNS[$pattern_name]}" "$pattern_name"
                    echo ""
                    read -p "Generate this pattern? (y/N): " -n 1 -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        generate_commit_art "${PATTERNS[$pattern_name]}" "$pattern_name"
                    fi
                else
                    echo "Pattern '$2' not found."
                    echo ""
                    show_patterns
                    exit 1
                fi
            fi
            ;;
        "help"|"-h"|"--help"|"")
            echo "Usage: $0 COMMAND [ARGS]"
            echo ""
            echo "Commands:"
            echo "  list                    Show available patterns"
            echo "  preview PATTERN_NAME    Preview a pattern in terminal"
            echo "  generate PATTERN_NAME   Generate commit art for pattern"
            echo "  generate custom         Create and generate custom pattern"
            echo "  help                    Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 list"
            echo "  $0 preview heart"
            echo "  $0 generate love"
            echo "  $0 generate custom"
            echo ""
            show_patterns
            ;;
        *)
            echo "Unknown command: $1"
            echo "Run '$0 help' for usage information."
            exit 1
            ;;
    esac
}

main "$@"
