#!/bin/bash

STUDENT_NAME="$1"
STUDENT_IP="$2"
LAB_NUMBER="$3"

VALIDATOR="/var/www/private_data/lab/validator-2026.sh"
SSH_KEY="/home/validator/.ssh/id_rsa"
REMOTE_VALIDATOR="/tmp/linoop-validator-${LAB_NUMBER}-$$.sh"

if [ -z "$STUDENT_NAME" ] || [ -z "$STUDENT_IP" ] || [ -z "$LAB_NUMBER" ]; then
    echo "Invalid validation request."
    exit 1
fi

echo "Sit tight. Validation of your $LAB_NUMBER is in process. Good luck....."

# Copy validator to student's VM
scp \
    -i "$SSH_KEY" \
    -o BatchMode=yes \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o LogLevel=ERROR \
    "$VALIDATOR" \
    "$STUDENT_NAME@$STUDENT_IP:$REMOTE_VALIDATOR"

if [ $? -ne 0 ]; then
    exit 1
fi

# Always attempt remote cleanup when this script exits
cleanup() {
    ssh \
        -i "$SSH_KEY" \
        -o BatchMode=yes \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o LogLevel=ERROR \
        "$STUDENT_NAME@$STUDENT_IP" \
        "rm -f '$REMOTE_VALIDATOR'" \
        >/dev/null 2>&1
}

trap cleanup EXIT

# Run validator on student's VM
ssh \
    -i "$SSH_KEY" \
    -o BatchMode=yes \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o LogLevel=ERROR \
    "$STUDENT_NAME@$STUDENT_IP" \
    "export STUDENT_NAME='$STUDENT_NAME';
     export LAB_NUMBER='$LAB_NUMBER';

     trap 'rm -f \"$REMOTE_VALIDATOR\"' EXIT;

     source '$REMOTE_VALIDATOR';

     case \"\$LAB_NUMBER\" in
        lab201) validate_lab201_commands_sysinfo ;;
        lab202) validate_lab202_linuxfs_navigation_fsmgt ;;
        lab203) validate_lab203_command_navigation ;;
        lab204) validate_lab204_review_navigation ;;
        lab205) validate_lab205_file_permissions ;;
        lab206) validate_lab206_file_permissionsII ;;
        lab207) validate_lab207_ownership_group_management ;;
        lab208) validate_lab208_linux_file_links ;;
        lab209) validate_lab209_linux_admin_onboarding ;;
        lab210) validate_lab210_tar_backup_management ;;
        lab211) validate_lab211_production_portal_mgt ;;
        lab212) validate_lab212_find_grep ;;
        lab213) validate_lab213_vim_editor ;;
        lab214) validate_lab214_morning_incident ;;
        lab215) validate_lab215_process_management ;;
        lab216) validate_lab216_advanced_process_management ;;
        lab217) validate_lab217_service_management ;; 
        lab218) validate_lab218_advanced_service_management ;;
        lab219) validate_lab219_user_management ;;
        lab220) validate_lab220_advanced_user_management ;;
        lab221) validate_lab221_package_management ;;
        lab222) validate_lab222_advanced_package_management ;;

        *) echo 'Invalid lab'; exit 1 ;;
     esac"

exit $?
