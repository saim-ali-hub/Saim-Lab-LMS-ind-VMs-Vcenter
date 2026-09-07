#!/bin/bash

# ============================================================
# Lab 222 - Linux Package Management - Advanced
# Automated Task Completion Script
# ============================================================
HOME_DIR=/home/saim
LAB_DIR="$HOME_DIR/lab222_pkg_mgt"

echo "============================================================"
echo " Lab 222 - Linux Package Management - Advanced"
echo "============================================================"
echo ""

# ------------------------------------------------------------
# Task 1 - Identify DNF Package Manager
# ------------------------------------------------------------

echo "Task 1 - Identifying DNF package manager..."

mkdir -p "$LAB_DIR"

dnf --version > "$LAB_DIR/package_manager.txt" 2>&1

echo "Task 1 completed."
echo ""


# ------------------------------------------------------------
# Task 2 - Display Installed Packages
# ------------------------------------------------------------

echo "Task 2 - Displaying installed packages..."

dnf list installed > "$LAB_DIR/installed_packages.txt" 2>&1

echo "Task 2 completed."
echo ""


# ------------------------------------------------------------
# Task 3 - Search for nfs-utils Package
# ------------------------------------------------------------

echo "Task 3 - Searching for nfs-utils package..."

dnf search nfs-utils > "$LAB_DIR/nfs-utils_search.txt" 2>&1

echo "Task 3 completed."
echo ""


# ------------------------------------------------------------
# Task 4 - Display nfs-utils Package Information
# ------------------------------------------------------------

echo "Task 4 - Displaying nfs-utils package information..."

dnf info nfs-utils > "$LAB_DIR/nfs-utils_info.txt" 2>&1

echo "Task 4 completed."
echo ""


# ------------------------------------------------------------
# Task 5 - Determine if nfs-utils is Installed
# ------------------------------------------------------------

echo "Task 5 - Checking whether nfs-utils is installed..."

dnf list installed nfs-utils > "$LAB_DIR/nfs-utils_installed.txt" 2>&1

echo "Task 5 completed."
echo ""


# ------------------------------------------------------------
# Task 6 - Find Package Providing curl
# ------------------------------------------------------------

echo "Task 6 - Finding package that provides curl..."

dnf provides '*/curl' > "$LAB_DIR/curl_provider.txt" 2>&1

echo "Task 6 completed."
echo ""


# ------------------------------------------------------------
# Task 7 - Install nfs-utils
# ------------------------------------------------------------

echo "Task 7 - Installing nfs-utils..."

dnf install nfs-utils -y

echo ""
echo "Verifying nfs-utils installation..."

dnf list installed nfs-utils > "$LAB_DIR/nfs-utils_install_status.txt" 2>&1

echo "Task 7 completed."
echo ""


# ------------------------------------------------------------
# Task 8 - RPM Package Information
# ------------------------------------------------------------

echo "Task 8 - Displaying RPM package information..."

rpm -qi nfs-utils > "$LAB_DIR/rpm_package_info.txt" 2>&1

echo "Task 8 completed."
echo ""


# ------------------------------------------------------------
# Task 9 - List Files Installed by nfs-utils
# ------------------------------------------------------------

echo "Task 9 - Listing files installed by nfs-utils..."

rpm -ql nfs-utils > "$LAB_DIR/package_files.txt" 2>&1

echo "Task 9 completed."
echo ""


# ------------------------------------------------------------
# Task 10 - Determine Package Ownership of /etc/hostname
# ------------------------------------------------------------

echo "Task 10 - Finding package ownership of /etc/hostname..."

rpm -qf /etc/hostname > "$LAB_DIR/hostname_owner.txt" 2>&1

echo "Task 10 completed."
echo ""


# ------------------------------------------------------------
# Task 11 - Check Available Updates
# ------------------------------------------------------------

echo "Task 11 - Checking for available updates..."

dnf check-update > "$LAB_DIR/available_updates.txt" 2>&1

# dnf check-update returns:
# 0   = no updates available
# 100 = updates are available
# Other values may indicate an actual error.
#
# We intentionally do not use the exit status here because
# exit code 100 is a normal result when updates are available.

echo "Task 11 completed."
echo ""


# ------------------------------------------------------------
# Task 12 - Display Enabled Repositories
# ------------------------------------------------------------

echo "Task 12 - Displaying enabled repositories..."

dnf repolist > "$LAB_DIR/enabled_repositories.txt" 2>&1

echo "Task 12 completed."
echo ""


# ------------------------------------------------------------
# Task 13 - Remove nfs-utils
# ------------------------------------------------------------

echo "Task 13 - Removing nfs-utils..."

dnf remove nfs-utils -y

echo ""
echo "Verifying nfs-utils removal..."

dnf list installed nfs-utils > "$LAB_DIR/nfs-utils_remove_status.txt" 2>&1

echo "Task 13 completed."
echo ""


# ------------------------------------------------------------
# Completion
# ------------------------------------------------------------

echo "============================================================"
echo " Lab 222 completed successfully."
echo "============================================================"
echo ""
echo "Lab files created in:"
echo "$LAB_DIR"
echo ""
echo "Files:"
ls -lh "$LAB_DIR"
echo ""
