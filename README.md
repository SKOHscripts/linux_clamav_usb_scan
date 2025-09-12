# linux-clamav_usb_scan

<img align="right" src="https://www.clamav.net/assets/clamav-trademark.png">

[![support](https://brianmacdonald.github.io/Ethonate/svg/eth-support-blue.svg)](https://brianmacdonald.github.io/Ethonate/address#0xEDa4b087fac5faa86c43D0ab5EfCa7C525d475C2)

### Overview

This script is a **robust shell utility** designed to scan directories for viruses using the open-source **ClamAV** engine. It combines **automated updates**, **safe scanning**, clear log reporting, and offers both command-line and graphical dialogs via Zenity for an optimal user experience.

## Features

- **Antivirus scan** with ClamAV (`clamscan`)
- **Automatic update** of virus definitions before every scan (`freshclam`)
- **Graphical dialogs** for selection and notifications (Zenity)
- **Safe logging**: scan results saved with timestamp
- **Dependency check**: verifies required software is installed
- **User-friendly interface**: color-coded output and clear prompts
- **Error handling**: manages edge cases and interruptions
- **Git integration**: detects if target directory is a Git repo and shows last commit info

## Requirements

- Linux (tested on Ubuntu, Debian, Arch, etc.)
- ClamAV (`clamav`, `clamav-daemon`)
- Zenity (`zenity`)
- Notify-send (`libnotify-bin`)
- Bash (scripted for bash usage)

## Installation

1. **Clone or download** the script file (`clamav.sh`).
2. Ensure dependencies:
```
   sudo apt install clamav clamav-daemon zenity libnotify-bin
```

3. Make the script executable:
```
   chmod +x clamav.sh
```

## Usage

### Standard usage (with Zenity GUI):

```bash
./clamav.sh
```

- **Database update**: You may be prompted for `sudo` password to update virus definitions.
- **Directory selection**: Choose the folder you want to scan via a file picker.
- **Notifications**: Desktop notifications follow each step.
- **Log file**: The scan report is saved in a timestamped `.log` file.
- **View details**: Option to see log/report at the end of the scan.

### Command-line fallback

If Zenity is not installed, the script falls back to text prompts.

## Key Functions

- **print_status**: Shows colored status messages ([INFO], [WARN], [ERROR], [SUCCESS])
- **print_progress**: Displays a dynamic progress bar that fills the terminal line
- **check_dependencies**: Ensures that all required tools are present
- **update_clamav_db**: Updates virus definitions before scanning
- **select_scan_directory**: Chooses the target folder graphically or via text input
- **perform_scan**: Executes ClamAV scan, logs results, and summarizes findings
- **print_git_info**: Displays last git commit if the scanned folder is a repository

## Output

- **Scan log**: A file `clamav_scan_YYYYMMDD_HHMMSS.log` is created in the working directory
- **Notifications**: Desktop popups for key steps (requires notification system)
- **Exit codes**: Script uses meaningful exit codes for automation and troubleshooting

## Customization & Advanced Usage

- **Scan options**: Edit the `clamscan` command in the script for deeper scan settings
- **Integration**: Easily embedded in cron jobs or CI/CD (check exit codes for infection status)
- **Sudo policy**: Script enforces non-root usage except for freshclam database update

## Troubleshooting

- **Missing dependencies**: The script will list missing commands and show install tips before exit
- **Zenity warnings**: GTK/Adwaita warnings can be resolved by cleaning your `~/.config/gtk-4.0/settings.ini`
- **Permission issues**: Run as normal user, enter `sudo` working password only when prompted for database updates

## Example

```bash
./clamav.sh
# Select folder -> Wait for scan -> View report > If infected files, take appropriate action!
```

## References

- [ClamAV Documentation](http://www.clamav.net/)
- [Zenity Documentation](https://www.tecmint.com/zenity-create-gtk-dialog-boxes-in-linux/)

***

**This script makes Linux file scanning with ClamAV simple, elegant and transparent for power users and non-technical users alike.**
