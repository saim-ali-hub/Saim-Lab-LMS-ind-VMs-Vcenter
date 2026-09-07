#!/bin/bash

# ============================================================
# Lab 221 - Linux Package Management
# Automated Task Completion Script
# ============================================================
HOME_DIR=/home/saim
LAB_DIR="$HOME_DIR/lab221_pkg_mgt"

echo "============================================================"
echo " Lab 221 - Linux Package Management"
echo "============================================================"
echo ""

# ------------------------------------------------------------
# Task 1 - Identify Package Manager
# ------------------------------------------------------------

echo "Task 1 - Identifying package manager..."

yum remove httpd -y

mkdir -p "$LAB_DIR"

yum --version > "$LAB_DIR/package_manager.txt" 2>&1

echo "Task 1 completed."
echo ""


# ------------------------------------------------------------
# Task 2 - Display Installed Packages
# ------------------------------------------------------------

echo "Task 2 - Displaying installed packages..."

yum list installed > "$LAB_DIR/installed_packages.txt" 2>&1

echo "Task 2 completed."
echo ""


# ------------------------------------------------------------
# Task 3 - Search for httpd Package
# ------------------------------------------------------------

echo "Task 3 - Searching for httpd package..."

yum search httpd > "$LAB_DIR/httpd_search.txt" 2>&1

echo "Task 3 completed."
echo ""


# ------------------------------------------------------------
# Task 4 - Display httpd Package Information
# ------------------------------------------------------------

echo "Task 4 - Displaying httpd package information..."

yum info httpd > "$LAB_DIR/httpd_info.txt" 2>&1

echo "Task 4 completed."
echo ""


# ------------------------------------------------------------
# Task 5 - Determine if httpd is Installed
# ------------------------------------------------------------

echo "Task 5 - Checking whether httpd is installed..."

yum list installed httpd > "$LAB_DIR/httpd_installed.txt" 2>&1

echo "Task 5 completed."
echo ""


# ------------------------------------------------------------
# Task 6 - Find Package Providing curl
# ------------------------------------------------------------

echo "Task 6 - Finding package that provides curl..."

yum provides '*/curl' > "$LAB_DIR/curl_provider.txt" 2>&1

echo "Task 6 completed."
echo ""


# ------------------------------------------------------------
# Task 7 - Install httpd
# ------------------------------------------------------------

echo "Task 7 - Installing httpd..."

yum install httpd -y

echo ""
echo "Verifying httpd installation..."

yum list installed httpd > "$LAB_DIR/httpd_install_status.txt" 2>&1

echo "Task 7 completed."
echo ""


# ------------------------------------------------------------
# Task 8 - Remove httpd
# ------------------------------------------------------------

echo "Task 8 - Removing httpd..."

yum remove httpd -y

echo ""
echo "Verifying httpd removal..."

yum list installed httpd > "$LAB_DIR/httpd_remove_status.txt" 2>&1

echo "Task 8 completed."
echo ""


# ------------------------------------------------------------
# Completion
# ------------------------------------------------------------

echo "============================================================"
echo " Lab 221 completed successfully."
echo "============================================================"
echo ""
echo "Lab files created in:"
echo "$LAB_DIR"
echo ""
echo "Files:"
ls -lh "$LAB_DIR"
echo ""
