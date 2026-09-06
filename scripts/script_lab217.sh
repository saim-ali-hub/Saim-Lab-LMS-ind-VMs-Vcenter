#!/bin/bash

# ============================================================
# Lab 217 - Linux Service Management
# Automated Task Execution Script
# ============================================================

# ------------------------------------------------------------
# Make sure script is running as root
# ------------------------------------------------------------

if [ "$EUID" -ne 0 ]; then
    echo "Root privileges are required."
    echo "Re-running script with sudo..."
    exec sudo "$0" "$@"
fi

# ------------------------------------------------------------
# Variables
# ------------------------------------------------------------

STUDENT_HOME="${SUDO_USER:+$(eval echo "~$SUDO_USER")}"

if [ -z "$STUDENT_HOME" ] || [ "$STUDENT_HOME" = "~" ]; then
    STUDENT_HOME="$HOME"
fi

BASE="$STUDENT_HOME/service_mgt"

echo
echo "============================================================"
echo " Lab 217 - Linux Service Management"
echo "============================================================"
echo

# ============================================================
# TASK 1 - CREATE SERVICE_MGT DIRECTORY
# ============================================================

echo "Task 1 - Creating service_mgt directory..."

mkdir -p "$BASE"

cd "$BASE" || {
    echo "ERROR: Unable to enter $BASE"
    exit 1
}

echo "Working directory:"
pwd

echo "Task 1 completed."
echo

# ============================================================
# TASK 2 - IDENTIFY SERVICE MANAGER
# ============================================================

echo "Task 2 - Identifying Service Manager..."

ps -p 1 -o pid,comm,cmd

echo
echo "Service manager identified as:"
ps -p 1 -o comm=

echo

# ============================================================
# TASK 3 - CHECK SERVICE STATUS
# ============================================================

echo "Task 3 - Checking httpd service..."

# Check if httpd is installed
if ! rpm -q httpd >/dev/null 2>&1; then
    echo "httpd is not installed."
    echo "Installing httpd..."

    dnf install httpd -y
fi

# Save service status
systemctl status httpd > "$BASE/httpd_status3" 2>&1

echo "Saved output to:"
echo "$BASE/httpd_status3"

echo

# ============================================================
# TASK 4 - STOP SERVICE
# ============================================================

echo "Task 4 - Stopping httpd service..."

systemctl stop httpd

systemctl status httpd > "$BASE/httpd_status4" 2>&1

echo "httpd status after stop:"
systemctl is-active httpd 2>/dev/null || true

echo
echo "Saved output to:"
echo "$BASE/httpd_status4"

echo

# ============================================================
# TASK 5 - START SERVICE
# ============================================================

echo "Task 5 - Starting httpd service..."

systemctl start httpd

systemctl status httpd > "$BASE/httpd_status5" 2>&1

echo "httpd status after start:"
systemctl is-active httpd

echo
echo "Saved output to:"
echo "$BASE/httpd_status5"

echo

# ============================================================
# TASK 6 - RESTART SERVICE
# ============================================================

echo "Task 6 - Restarting httpd service..."

systemctl restart httpd

systemctl status httpd > "$BASE/httpd_status6" 2>&1

echo "httpd status after restart:"
systemctl is-active httpd

echo
echo "Saved output to:"
echo "$BASE/httpd_status6"

echo

# ============================================================
# TASK 7 - RELOAD SERVICE
# ============================================================

echo "Task 7 - Reloading httpd service..."

systemctl reload httpd

systemctl status httpd > "$BASE/httpd_status7" 2>&1

echo "httpd status after reload:"
systemctl is-active httpd

echo
echo "Saved output to:"
echo "$BASE/httpd_status7"

echo
echo "Restart vs Reload:"
echo "  restart -> stops and starts the service"
echo "  reload  -> reloads configuration without completely"
echo "             stopping the service"
echo

# ============================================================
# TASK 8 - ENABLE SERVICE AT BOOT
# ============================================================

echo "Task 8 - Enabling httpd at boot..."

systemctl enable httpd

systemctl status httpd > "$BASE/httpd_status8" 2>&1

echo
echo "Enabled state:"
systemctl is-enabled httpd

echo
echo "Saved output to:"
echo "$BASE/httpd_status8"

echo

# ============================================================
# TASK 9 - DISABLE SERVICE AT BOOT
# ============================================================

echo "Task 9 - Disabling httpd at boot..."

systemctl disable httpd

systemctl status httpd > "$BASE/httpd_status9" 2>&1

echo
echo "Enabled state:"
systemctl is-enabled httpd

echo
echo "Saved output to:"
echo "$BASE/httpd_status9"

echo

# ============================================================
# TASK 10 - VIEW SERVICE INFORMATION
# ============================================================

echo "Task 10 - Viewing detailed httpd service information..."

systemctl status httpd > "$BASE/httpd_status10" 2>&1

echo "Saved output to:"
echo "$BASE/httpd_status10"

echo
echo "Important information:"
echo "------------------------------------------------------------"

grep -E "Loaded:|Active:|Main PID:|Description:" \
    "$BASE/httpd_status10" || true

echo

# ============================================================
# TASK 11 - FIND SERVICE PROCESS
# ============================================================

echo "Task 11 - Finding httpd service process..."

ps -C httpd -o pid,ppid,user,comm > "$BASE/httpd_status11"

echo "Saved output to:"
echo "$BASE/httpd_status11"

echo
echo "httpd processes:"
echo "------------------------------------------------------------"
cat "$BASE/httpd_status11"

echo

# ============================================================
# FINAL SUMMARY
# ============================================================

echo " Lab 217 Completed"
