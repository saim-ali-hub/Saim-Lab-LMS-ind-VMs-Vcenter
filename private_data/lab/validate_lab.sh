#!/bin/bash
STUDENT_NAME="$1"
LAB_NUMBER="$2"

if [ -z "$STUDENT_NAME" ] || [ -z "$LAB_NUMBER" ]; then
    echo "Usage: $0 <student_name> <lab_number>"
    exit 1
fi


if ! id "$STUDENT_NAME" >/dev/null 2>&1; then
    echo "Error: Student user '$STUDENT_NAME' does not exist."
    exit 1
fi

# Prevent unexpected characters in username
if ! [[ "$STUDENT_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    echo "Error: Invalid student username."
    exit 1
fi

# VARIABLES
export STUDENT_NAME
export LAB_NUMBER

HOME_DIR="/home/$STUDENT_NAME"

if [ ! -d "$HOME_DIR" ]; then
    echo "Error: Home directory not found: $HOME_DIR"
    exit 1
fi

# VALIDATOR LIBRARY
VALIDATOR="/var/www/private_data/lab/validator-2026.sh"
# LOAD VALIDATION FUNCTIONS
source "$VALIDATOR"

if [ $? -ne 0 ]; then
    echo "Error: Unable to load validator library."
    exit 1
fi

# RUN SELECTED LAB

echo "Sit tight. Validation of your $LAB_NUMBER is in process. Good luck....."

case "$LAB_NUMBER" in

    lab201)
        validate_lab201_commands_sysinfo 
        ;;

    lab202)
        validate_lab202_linuxfs_navigation_fsmgt
        ;;

    lab203)
        validate_lab203_command_navigation
        ;;

    lab204)
        validate_lab204_review_navigation
        ;;
    lab205)
        validate_lab205_file_permissions
        ;;
    lab206)
        validate_lab206_file_permissionsII
        ;;
    lab207)
        validate_lab207_ownership_group_management
        ;;
    lab208)
        validate_lab208_linux_file_links
        ;;
    lab209)
        validate_lab209_linux_admin_onboarding
        ;;
    lab210)
        validate_lab210_tar_backup_management
        ;;
    lab211)
        validate_lab211_production_portal_mgt
        ;;
    lab212)
        validate_lab212_find_grep
        ;;
    lab213)
        validate_lab213_vim_editor
        ;;	 
    lab214)
        validate_lab214_morning_incident
        ;;
    *)

        echo "Invalid lab: $LAB_NUMBER"
        exit 1
        ;;

esac

exit 0
