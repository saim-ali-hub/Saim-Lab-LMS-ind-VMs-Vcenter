#!/bin/bash

# ============================================================
# Lab 218 - Advanced Linux Service Management
# Task Automation Script
# ============================================================

set +e
set +u
set +o pipefail

LAB_NAME="Lab 218 - Advanced Linux Service Management"

# ------------------------------------------------------------
# Determine student and home directory
# ------------------------------------------------------------

if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ]; then
    STUDENT_NAME="$SUDO_USER"
else
    STUDENT_NAME="${STUDENT_NAME:-$(logname 2>/dev/null)}"
fi

HOME_DIR="/home/$STUDENT_NAME"
BASE="$HOME_DIR/lab218_service_mgt_advance"

echo "============================================================"
echo "$LAB_NAME"
echo "============================================================"
echo
echo "Student      : $STUDENT_NAME"
echo "Home         : $HOME_DIR"
echo "Lab Workspace: $BASE"
echo

# ------------------------------------------------------------
# Make sure script is running as root
# ------------------------------------------------------------

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root."
    echo
    echo "Run:"
    echo "sudo bash lab218.sh"
    exit 1
fi

# ============================================================
# TASK 1 - CREATE LAB WORKSPACE
# ============================================================

echo "============================================================"
echo "TASK 1 - Create the Lab Workspace"
echo "============================================================"

mkdir -p "$BASE"

cd "$BASE" || {
    echo "ERROR: Cannot change to $BASE"
    exit 1
}

echo "Lab workspace created:"
pwd

echo "Workspace path saved to task1_workspace.txt"
{
    echo "Lab 218 - Workspace"
    echo "Student: $STUDENT_NAME"
    echo "Home Directory: $HOME_DIR"
    echo "Workspace: $BASE"
    echo "Current Directory: $(pwd)"
} > "$BASE/task1_workspace.txt"

echo


# ============================================================
# TASK 2 - IDENTIFY SERVICE MANAGER
# ============================================================

echo "============================================================"
echo "TASK 2 - Identify the Service Manager"
echo "============================================================"

ps -p 1 -o pid,comm,cmd > "$BASE/task2_service_manager.txt"

echo "PID 1 information:"
cat "$BASE/task2_service_manager.txt"

echo

if ps -p 1 -o comm= | grep -qx "systemd"; then
    echo "Service manager identified: systemd"
    echo "Service Manager: systemd" >> "$BASE/task2_service_manager.txt"
else
    echo "WARNING: PID 1 is not systemd."
fi

echo


# ============================================================
# TASK 3 - INSPECT APACHE BEFORE STARTING
# ============================================================

echo "============================================================"
echo "TASK 3 - Inspect Apache Before Starting"
echo "============================================================"

{
    echo "============================================================"
    echo "Lab 218 - Apache Status Before Starting"
    echo "============================================================"
    echo

    echo "----- systemctl status httpd -----"
    systemctl status httpd --no-pager

    echo
    echo "----- Loaded State -----"
    systemctl show httpd -p LoadState

    echo
    echo "----- Active State -----"
    systemctl show httpd -p ActiveState

    echo
    echo "----- Main PID -----"
    systemctl show httpd -p MainPID

    echo
    echo "----- Service File Location -----"
    systemctl show httpd -p FragmentPath

    echo
    echo "----- Enabled / Disabled State -----"
    systemctl is-enabled httpd 2>&1

} > "$BASE/task3_httpd_status.txt"

echo "Apache status saved to:"
echo "$BASE/task3_httpd_status.txt"

echo
echo "Current Apache state:"
systemctl is-active httpd 2>&1

echo


# ============================================================
# TASK 4 - START APACHE
# ============================================================

echo "============================================================"
echo "TASK 4 - Start Apache"
echo "============================================================"

systemctl start httpd

{
    echo "============================================================"
    echo "Lab 218 - Apache After Start"
    echo "============================================================"
    echo

    systemctl status httpd --no-pager

    echo
    echo "----- Active State -----"
    systemctl is-active httpd

} > "$BASE/task4_httpd.txt"

echo "Apache status saved to:"
echo "$BASE/task4_httpd.txt"

echo
echo "Apache active state:"
systemctl is-active httpd

echo


# ============================================================
# TASK 5 - ENABLE APACHE AT BOOT
# ============================================================

echo "============================================================"
echo "TASK 5 - Enable Apache at Boot"
echo "============================================================"

systemctl enable httpd

{
    echo "============================================================"
    echo "Lab 218 - Apache Enabled at Boot"
    echo "============================================================"
    echo

    echo "----- systemctl status httpd -----"
    systemctl status httpd --no-pager

    echo
    echo "----- Enabled State -----"
    systemctl is-enabled httpd

} > "$BASE/task5_httpd_status.txt"

echo "Apache boot configuration saved to:"
echo "$BASE/task5_httpd_status.txt"

echo
echo "Enabled state:"
systemctl is-enabled httpd

echo


# ============================================================
# TASK 6 - CREATE WEB CONTENT
# ============================================================

echo "============================================================"
echo "TASK 6 - Create Web Content"
echo "============================================================"

WEBROOT="/var/www/html"
INDEX="$WEBROOT/index.html"

mkdir -p "$WEBROOT"

cat > "$INDEX" <<'EOF'
<h1>LINOOP Linux Service Management</h1>

<p>Apache HTTP Server is running successfully.</p>

<p>Lab 218 - Advanced Service Management</p>
EOF

echo "Web content created:"
echo "$INDEX"

echo
echo "----- index.html -----"
cat "$INDEX"

{
    echo "============================================================"
    echo "Lab 218 - Web Content"
    echo "============================================================"
    echo
    echo "File: $INDEX"
    echo
    cat "$INDEX"
} > "$BASE/task6_web_content.txt"

echo


# ============================================================
# TASK 7 - ACCESS WEB SERVER
# ============================================================

echo "============================================================"
echo "TASK 7 - Access the Web Server"
echo "============================================================"

SERVER_IP=$(hostname -I | awk '{print $1}')

echo "Server IP: $SERVER_IP"
echo
echo "Open the following URL in a browser:"
echo
echo "http://$SERVER_IP"
echo

{
    echo "Lab 218 - Web Server Access"
    echo "Server Hostname: $(hostname)"
    echo "Server IP: $SERVER_IP"
    echo "URL: http://$SERVER_IP"
    echo
    echo "Browser verification must be performed manually."
} > "$BASE/task7_web_access.txt"

echo "Server information saved to:"
echo "$BASE/task7_web_access.txt"

echo


# ============================================================
# TASK 8 - STOP HTTPD
# ============================================================

echo "============================================================"
echo "TASK 8 - Stop httpd Service"
echo "============================================================"

systemctl stop httpd

{
    echo "============================================================"
    echo "Lab 218 - Apache After Stop"
    echo "============================================================"
    echo

    systemctl status httpd --no-pager

    echo
    echo "----- Active State -----"
    systemctl is-active httpd 2>&1

} > "$BASE/task8_httpd_status.txt"

echo "Apache has been stopped."

echo
echo "Current Apache state:"
systemctl is-active httpd 2>&1

echo

echo "Status saved to:"
echo "$BASE/task8_httpd_status.txt"

echo


# ============================================================
# TASK 9 - TEST WEBSITE AFTER STOPPING HTTPD
# ============================================================

echo "============================================================"
echo "TASK 9 - Test Website After Stopping httpd"
echo "============================================================"

echo "The Apache service is currently stopped."
echo
echo "Return to your browser and refresh:"
echo "http://$SERVER_IP"
echo
echo "The website should NOT be accessible."
echo
echo "The HTML file still exists:"
echo "$INDEX"
echo

{
    echo "============================================================"
    echo "Lab 218 - Apache Stopped / Website Test"
    echo "============================================================"
    echo

    echo "----- Apache Service State -----"
    systemctl is-active httpd 2>&1

    echo
    echo "----- HTML File -----"

    if [ -f "$INDEX" ]; then
        echo "index.html exists"
        ls -l "$INDEX"
    else
        echo "index.html is missing"
    fi

    echo
    echo "----- Browser Test -----"
    echo "Browser verification must be performed manually."
    echo "Expected result: Website unavailable because httpd is stopped."

} > "$BASE/task9_httpd_status.txt"

echo "Task 9 information saved to:"
echo "$BASE/task9_httpd_status.txt"

echo


# ============================================================
# TASK 10 - RESTART APACHE
# ============================================================

echo "============================================================"
echo "TASK 10 - Restart Apache"
echo "============================================================"

systemctl restart httpd

{
    echo "============================================================"
    echo "Lab 218 - Apache After Restart"
    echo "============================================================"
    echo

    systemctl status httpd --no-pager

    echo
    echo "----- Active State -----"
    systemctl is-active httpd

} > "$BASE/task10_httpd_status.txt"

echo "Apache restarted."

echo
echo "Current Apache state:"
systemctl is-active httpd

echo

echo "Status saved to:"
echo "$BASE/task10_httpd_status.txt"

echo


# ============================================================
# TASK 11 - ACCESS WEBSITE AGAIN
# ============================================================

echo "============================================================"
echo "TASK 11 - Access Website Again"
echo "============================================================"

FINAL_STATE=$(systemctl is-active httpd)

echo "Final Apache state: $FINAL_STATE"
echo
echo "Return to your browser and refresh:"
echo "http://$SERVER_IP"
echo
echo "The website should now be accessible again."

echo

echo "Expected content:"
echo
cat "$INDEX"

echo

echo "$FINAL_STATE" > "$BASE/task11_httpd_accessible.txt"

echo "Final service state saved to:"
echo "$BASE/task11_httpd_accessible.txt"

echo


# ============================================================
# FINAL SUMMARY
# ============================================================

echo "============================================================"
echo "LAB 218 AUTOMATION COMPLETE"
echo "============================================================"

echo
echo "Workspace:"
echo "$BASE"

echo
echo "Files created:"
echo

ls -lh "$BASE"

echo
echo "Final Apache state:"
systemctl is-active httpd

echo
echo "Apache enabled at boot:"
systemctl is-enabled httpd

echo
echo "Server IP:"
echo "$SERVER_IP"

echo
echo "============================================================"
echo "MANUAL VERIFICATION REQUIRED"
echo "============================================================"

echo
echo "Task 7:"
echo "  Open http://$SERVER_IP in a browser."
echo
echo "Task 9:"
echo "  Refresh the browser while httpd is stopped."
echo "  The website should be unavailable."
echo
echo "Task 11:"
echo "  Refresh the browser after Apache is restarted."
echo "  The website should be accessible again."
echo

echo "============================================================"
echo "Lab 218 completed."
echo "============================================================"
