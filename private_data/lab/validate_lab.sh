#!/bin/bash

set -u

VALIDATOR_SCRIPT="/var/www/private_data/lab/validator-2026.sh"
SSH_KEY="/home/validator/.ssh/id_rsa"

# ARGUMENT VALIDATION
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <student> <ip> <lab>"
    exit 1
fi

STUDENT_NAME="$1"
MACHINE_IPV4="$2"
LAB_NUMBER="$3"

# Validate student username
if [[ ! "$STUDENT_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    echo "Error: Invalid student username."
    exit 1
fi

# Validate IPv4 format
if [[ ! "$MACHINE_IPV4" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "Error: Invalid IPv4 address."
    exit 1
fi

# Validate lab number
if [[ ! "$LAB_NUMBER" =~ ^lab[0-9]+$ ]]; then
    echo "Error: Invalid lab number."
    exit 1
fi

# REQUIRED FILES
if [ ! -f "$SSH_KEY" ]; then
    echo "Error: Validator SSH private key not found."
    exit 1
fi

if [ ! -f "$VALIDATOR_SCRIPT" ]; then
    echo "Error: Validator script not found."
    exit 1
fi

# SSH OPTIONS
SSH_OPTS=(
    -i "$SSH_KEY"
    -o BatchMode=yes
    -o StrictHostKeyChecking=no
    -o UserKnownHostsFile=/dev/null
    -o ConnectTimeout=10
)

REMOTE="${STUDENT_NAME}@${MACHINE_IPV4}"

# ============================================================
# VERIFY SSH
# The SSH connection is made as the STUDENT.
# validator@VM  <-- NOT USED
# student@VM    <-- USED
# Therefore the validation script sees:
# /home/student
# whoami = student
# permissions = student
# ownership = student
# ============================================================

REMOTE_USER=$(
    ssh "${SSH_OPTS[@]}" \
    "$REMOTE" \
    "whoami" \
    2>/dev/null
)

if [ "$REMOTE_USER" != "$STUDENT_NAME" ]; then
    echo "Error: SSH student identity verification failed."
    exit 1
fi

# RANDOM REMOTE VALIDATOR PATH
REMOTE_LIB="/tmp/.linoop-validator.${RANDOM}.$$"

# CLEANUP
cleanup()
{
    ssh "${SSH_OPTS[@]}" \
        "$REMOTE" \
        "rm -f '$REMOTE_LIB'" \
        >/dev/null 2>&1 || true
}

trap cleanup EXIT

# COPY VALIDATOR TO STUDENT VM
if ! scp -q \
    "${SSH_OPTS[@]}" \
    "$VALIDATOR_SCRIPT" \
    "$REMOTE:$REMOTE_LIB"
then

    echo "Error: Failed to copy validator to student VM."
    exit 1

fi

# RUN VALIDATION
# stdout from the validator is returned directly to:
# evaluate_lab.php
# and then to:
# Browser
# No result file is created here.
echo "Sit tight. Validation of your $LAB_NUMBER is in process. Good luck....."

ssh \
    "${SSH_OPTS[@]}" \
    "$REMOTE" \
    "export STUDENT_NAME='$STUDENT_NAME';
     export LAB_NUMBER='$LAB_NUMBER';
     export REMOTE_LIB='$REMOTE_LIB';
     bash -s" <<'REMOTE_RUN'

# Validator functions should continue even when a task fails.

set +e
set +u
set +o pipefail

# Load validator library
source "$REMOTE_LIB"

# Run selected lab
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

    *)
        echo "Invalid lab: $LAB_NUMBER"
        exit 1
        ;;

esac

# Remove validator from student VM
rm -f "$REMOTE_LIB" || true

REMOTE_RUN

exit 0
