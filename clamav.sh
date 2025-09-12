#!/bin/bash
#######################################################################################
# ClamAV Antivirus Scanner
#
# Description: A robust shell script using the ClamAV open-source antivirus engine
#              to scan directories with enhanced error handling and user interface
#
# Author: Corentin Michel
# Contact: [corentin.michel@mailo.com](mailto:corentin.michel@mailo.com)
# GitHub: [https://github.com/SKOHscripts](https://github.com/SKOHscripts)
# License: All Rights Reserved
#
# Version: 2.0
#######################################################################################
set -euo pipefail  # Exit on error, undefined variables, pipe failures

# Color definitions
readonly RED='\e[1;31m'
readonly GREEN='\e[1;32m'
readonly YELLOW='\e[1;33m'
readonly BLUE='\e[1;34m'
readonly NEUTRAL='\e[0m'
readonly BOLD='\e[1m'

# Configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_FILE="clamav_scan_$(date +%Y%m%d_%H%M%S).log"
readonly MIN_COLUMNS=50

# Function to print colored output
print_status() {
    local level="$1"
    shift
    case "$level" in
        "info")  echo -e "${BLUE}[INFO]${NEUTRAL} $*" ;;
        "warn")  echo -e "${YELLOW}[WARN]${NEUTRAL} $*" ;;
        "error") echo -e "${RED}[ERROR]${NEUTRAL} $*" >&2 ;;
        "success") echo -e "${GREEN}[SUCCESS]${NEUTRAL} $*" ;;
    esac
}

# Function to print progress bars
print_progress() {
    local step="$1"
    local total="$2"
    local description="$3"
    local columns="${COLUMNS:-80}"

    if [[ $columns -lt $MIN_COLUMNS ]]; then
        columns=$MIN_COLUMNS
    fi
    local progress_prefix="${GREEN}[${step}/${total}]${RED} ${description} "
    local prefix_length=${#progress_prefix}
    local dots=$(( columns - prefix_length ))
    if [[ $dots -lt 0 ]]; then
        dots=0
    fi
    echo -en "${progress_prefix}"
    for ((i=0; i<dots; i++)); do
        echo -n "."
    done
    echo -e " ${NEUTRAL}"
}

# Function to check Git repository information
print_git_info() {
    local dir="$1"
    if [[ -d "${dir}/.git" ]]; then
        print_status "info" "Git repository detected"
        (
            cd "$dir" || return 1
            echo "Last commit:"
            git log -n 1 --oneline --date=short --pretty=format:"  %h - %s (%an, %ad)" 2>/dev/null || echo "  Unable to read git log"
        )
    else
        print_status "info" "Not a git repository"
    fi
}

# Function to check if running as root
check_root() {
    if [[ $UID -eq 0 ]]; then
        if command -v zenity &> /dev/null; then
            zenity --error \
                --height=150 \
                --width=450 \
                --title="Privilege Error" \
                --text="<b>This script should NOT be run with sudo!</b>\n\nUsage:\n<tt>./${SCRIPT_NAME}</tt>"
        else
            print_status "error" "This script should NOT be run with sudo!"
        fi
        exit 1
    fi
}

# Function to check dependencies
check_dependencies() {
    local missing_deps=()
    local deps=("notify-send" "zenity" "freshclam" "clamscan")
    print_status "info" "Checking dependencies..."
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_status "error" "Missing dependencies: ${missing_deps[*]}"
        case "${missing_deps[*]}" in
            *notify-send*)
                print_status "error" "Install libnotify-bin: sudo apt install libnotify-bin" ;;
            *zenity*)
                print_status "error" "Install zenity: sudo apt install zenity" ;;
            *freshclam*|*clamscan*)
                print_status "error" "Install clamav: sudo apt install clamav clamav-daemon" ;;
        esac
        exit 1
    fi
    print_status "success" "All dependencies are installed"
}

# Function to update ClamAV database
update_clamav_db() {
    print_progress "1" "2" "UPDATING VIRUS DATABASE"
    if command -v zenity &> /dev/null; then
        zenity --info \
            --width=400 \
            --height=150 \
            --title="ClamAV - Update" \
            --text="<b>Updating the antivirus database</b>\n\nYou may be asked for your sudo password."
    fi
    if command -v notify-send &> /dev/null; then
        notify-send -i system-software-update "ClamAV" "Updating virus database..."
    fi
    # Stop freshclam service if running
    print_status "info" "Stopping clamav-freshclam service..."
    sudo systemctl stop clamav-freshclam 2>/dev/null || print_status "warn" "Could not stop clamav-freshclam (maybe already stopped)"
    # Create log directory if it doesn't exist
    print_status "info" "Configuring log directories..."
    sudo mkdir -p /var/log/clamav/
    sudo chown -R clamav:clamav /var/log/clamav/ 2>/dev/null || print_status "warn" "Could not change log ownership"
    # Update virus database
    print_status "info" "Downloading updates..."
    if sudo freshclam; then
        print_status "success" "Database updated successfully"
    else
        print_status "warn" "Update failed, proceeding with old database"
    fi
    # Restart freshclam service
    print_status "info" "Restarting clamav-freshclam service..."
    sudo systemctl start clamav-freshclam 2>/dev/null || print_status "warn" "Could not restart clamav-freshclam"
    echo
}

# Function to select directory to scan
select_scan_directory() {
    local selected_dir=""
    if command -v zenity &> /dev/null; then
        zenity --info \
            --width=350 \
            --height=120 \
            --title="ClamAV - Selection" \
            --text="<b>Select the directory to scan</b>"
        selected_dir=$(zenity --file-selection --directory --title="Choose the directory to scan" 2>/dev/null || echo "")
    else
        print_status "info" "Enter the path for the directory to scan (or press Enter for current directory):"
        read -r selected_dir
        if [[ -z "$selected_dir" ]]; then
            selected_dir="$PWD"
        fi
    fi
    if [[ -z "$selected_dir" ]]; then
        print_status "warn" "No directory selected, using current directory"
        selected_dir="$PWD"
    fi
    if [[ ! -d "$selected_dir" ]]; then
        print_status "error" "Directory '$selected_dir' does not exist!"
        exit 1
    fi
    echo "$selected_dir"
}

# Function to perform ClamAV scan
perform_scan() {
    local scan_dir="$1"
    local real_path
    real_path=$(realpath "$scan_dir")
    print_progress "2" "2" "RUNNING VIRUS SCAN"
    print_status "info" "Scanning directory: $real_path"
    print_git_info "$real_path"
    if command -v notify-send &> /dev/null; then
        notify-send -i system-software-update "ClamAV" "Scanning: $(basename "$real_path")"
    fi
    # Initialize log file
    {
        echo "=================================="
        echo "ClamAV Scan Report"
        echo "Date: $(date)"
        echo "Directory: $real_path"
        echo "=================================="
        echo
    } > "$LOG_FILE"
    print_status "info" "Scan started (log: $LOG_FILE)..."
    echo
    # Perform scan with better options
    local scan_result=0
    clamscan \
        --recursive \
        --remove=no \
        --bell \
        --infected \
        --log="$LOG_FILE" \
        --verbose \
        "$real_path" || scan_result=$?
    echo
    # Analyze results
    case $scan_result in
        0)
            print_status "success" "Scan finished: No threats found"
            if command -v notify-send &> /dev/null; then
                notify-send -i dialog-ok "ClamAV" "Scan finished - No threats found"
            fi
            ;;
        1)
            print_status "warn" "Scan finished: Infected files detected!"
            if command -v notify-send &> /dev/null; then
                notify-send -i dialog-warning "ClamAV" "ATTENTION: Infected files detected!"
            fi
            ;;
        *)
            print_status "error" "Error during scan (code: $scan_result)"
            if command -v notify-send &> /dev/null; then
                notify-send -i dialog-error "ClamAV" "Error during scan"
            fi
            ;;
    esac
    # Show log file location
    print_status "info" "Detailed report available at: $LOG_FILE"
    # Offer to view results
    if command -v zenity &> /dev/null; then
        if zenity --question \
            --width=300 \
            --height=100 \
            --title="ClamAV - Results" \
            --text="Would you like to view the scan report?"; then
            if command -v xdg-open &> /dev/null; then
                xdg-open "$LOG_FILE" &
            elif command -v less &> /dev/null; then
                less "$LOG_FILE"
            else
                cat "$LOG_file"
            fi
        fi
    fi
    return $scan_result
}

# Function to display script header
print_header() {
    echo -e "${BOLD}${BLUE}"
    echo "=================================="
    echo "    ClamAV Antivirus Scanner"
    echo "=================================="
    echo -e "${NEUTRAL}"
    echo "Version 2.0 - $(date +%Y-%m-%d)"
    echo
}

# Function to cleanup on exit
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        print_status "error" "Script interrupted (code: $exit_code)"
    fi
    exit $exit_code
}

# Main function
main() {
    # Set up signal handlers
    trap cleanup EXIT INT TERM
    print_header
    # Perform checks
    check_root
    check_dependencies
    # Update antivirus database
    update_clamav_db
    # Select directory and perform scan
    local scan_directory
    scan_directory=$(select_scan_directory)
    perform_scan "$scan_directory"
    print_status "success" "Operation completed successfully!"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
