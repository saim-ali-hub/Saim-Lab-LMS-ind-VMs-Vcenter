#!/bin/bash

# ============================================================
# Lab 220 - Linux User Management - Advanced
# Task Execution Script
# ============================================================

STUDENT_NAME=saim
HOME_DIR=/home/saim
BASE="$HOME_DIR/lab219_user_mgt"

# ============================================================
# CREATE LAB DIRECTORY
# ============================================================

mkdir -p "$BASE"

echo "============================================================"
echo " Lab 220 - Linux User Management - Advanced"
echo "============================================================"
echo "Student : $STUDENT_NAME"
echo "Lab Dir : $BASE"
echo ""


# ============================================================
# TASK 1 - CREATE LAB DIRECTORY AND GROUPS
# ============================================================

echo "Task 1 - Creating groups..."

groupadd -g 3101 platform
groupadd -g 3102 developers
groupadd -g 3103 database
groupadd -g 3104 support

{
    getent group platform
    getent group developers
    getent group database
    getent group support
} > "$BASE/task1-groups.txt"

echo "Task 1 completed."
echo ""


# ============================================================
# TASK 2 - CREATE USERS WITH SPECIFIC UIDs
# ============================================================

echo "Task 2 - Creating users..."

useradd -u 2101 alex
useradd -u 2102 david
useradd -u 2103 maria
useradd -u 2104 sophia

{
    id alex
    id david
    id maria
    id sophia
} > "$BASE/task2-users.txt"

echo "Task 2 completed."
echo ""


# ============================================================
# TASK 3 - CONFIGURE SUPPLEMENTARY GROUPS
# ============================================================

echo "Task 3 - Configuring supplementary groups..."

usermod -aG developers alex
usermod -aG support alex

usermod -aG platform david
usermod -aG database david

usermod -aG developers maria

usermod -aG platform sophia
usermod -aG database sophia

{
    id alex
    id david
    id maria
    id sophia
} > "$BASE/task3-groups.txt"

echo "Task 3 completed."
echo ""


# ============================================================
# TASK 4 - ADD AND REMOVE SUPPLEMENTARY MEMBERSHIPS
# ============================================================

echo "Task 4 - Updating supplementary memberships..."

gpasswd -d david database
usermod -aG support maria
gpasswd -d sophia database

{
    id david
    id maria
    id sophia
} > "$BASE/task4-members.txt"

echo "Task 4 completed."
echo ""


# ============================================================
# TASK 5 - SET PASSWORDS
# ============================================================

echo "Task 5 - Setting passwords..."

echo "Set password for alex:"
passwd alex

echo "Set password for david:"
passwd david

echo "Set password for maria:"
passwd maria

echo "Set password for sophia:"
passwd sophia

{
    passwd -S alex
    passwd -S david
    passwd -S maria
    passwd -S sophia
} > "$BASE/task5-passwords.txt"

echo "Task 5 completed."
echo ""


# ============================================================
# TASK 6 - LOCK MARIA
# ============================================================

echo "Task 6 - Locking Maria's account..."

passwd -l maria

passwd -S maria > "$BASE/task6-lock-maria.txt"

echo "Task 6 completed."
echo ""


# ============================================================
# TASK 7 - UNLOCK MARIA
# ============================================================

echo "Task 7 - Unlocking Maria's account..."

passwd -u maria

passwd -S maria > "$BASE/task7-unlock-maria.txt"

echo "Task 7 completed."
echo ""


# ============================================================
# TASK 8 - REMOVE USERS FROM SUPPLEMENTARY GROUPS
# ============================================================

echo "Task 8 - Removing supplementary group memberships..."

gpasswd -d alex support
gpasswd -d alex developers

gpasswd -d maria support
gpasswd -d maria developers

gpasswd -d sophia platform

{
    id alex
    id maria
    id sophia
} > "$BASE/task8-membership-removal.txt"

echo "Task 8 completed."
echo ""


# ============================================================
# TASK 9 - DELETE DATABASE GROUP
# ============================================================

echo "Task 9 - Deleting database group..."

groupdel database

getent group database > "$BASE/task9-delete-database.txt"

echo "Task 9 completed."
echo ""


# ============================================================
# TASK 10 - DELETE SOPHIA
# ============================================================

echo "Task 10 - Deleting sophia..."

userdel -r sophia

{
    id sophia
    ls -ld /home/sophia
} > "$BASE/task10-delete-sophia.txt"

echo "Task 10 completed."
echo ""


# ============================================================
# TASK 11 - FINAL ACCOUNT CLEANUP
# ============================================================

echo "Task 11 - Final account cleanup..."

groupdel platform
groupdel support

{
    getent group support
    getent group platform
    getent group database
    getent group developers

    getent passwd alex
    getent passwd david
    getent passwd maria
    getent passwd sophia
} > "$BASE/task11-final-audit.txt"

echo "Task 11 completed."
echo ""


# ============================================================
# FINAL OWNERSHIP
# ============================================================

chown -R "$STUDENT_NAME:$STUDENT_NAME" "$BASE"


# ============================================================
# COMPLETION
# ============================================================

echo "============================================================"
echo " Lab 220 Completed Successfully"
echo "============================================================"
echo ""
echo "Verification files:"
ls -lh "$BASE"
echo ""
echo "Lab directory: $BASE"
echo "============================================================"

