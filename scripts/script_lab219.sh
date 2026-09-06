#!/bin/bash

# ============================================================
# Lab 219 - Linux User Management
# Task Execution Script
# ============================================================


STUDENT_NAME=saim
HOME_DIR="/home/saim"
BASE="/home/saim/lab219_user_mgt"

echo "============================================================"
echo " Lab 219 - Linux User Management"
echo "============================================================"
echo "Student : $STUDENT_NAME"
echo "Home    : $HOME_DIR"
echo "Lab Dir : $BASE"
echo ""

# ============================================================
# PREPARATION
# ============================================================

mkdir -p "$BASE"

# ============================================================
# TASK 1 - CREATE APPSUPPORT GROUP
# ============================================================

echo "Task 1 - Creating appsupport group..."

groupadd -g 3001 appsupport

getent group appsupport > "$BASE/task1-group.txt"

echo "Task 1 completed."
echo ""


# ============================================================
# TASK 2 - CREATE DEVELOPERS AND DBADMIN GROUPS
# ============================================================

echo "Task 2 - Creating developers and dbadmin groups..."

groupadd -g 3002 developers
groupadd -g 3003 dbadmin

{
    getent group developers
    getent group dbadmin
} > "$BASE/task2-groups.txt"

echo "Task 2 completed."
echo ""


# ============================================================
# TASK 3 - CREATE ALEX AND DAVID
# ============================================================

echo "Task 3 - Creating alex and david..."

useradd alex
useradd david

{
    getent passwd alex
    getent passwd david
} > "$BASE/task3-users.txt"

echo "Task 3 completed."
echo ""


# ============================================================
# TASK 4 - CREATE MARIA WITH UID 2001
# ============================================================

echo "Task 4 - Creating maria with UID 2001..."

useradd -u 2001 maria

id maria > "$BASE/task4-uid.txt"

echo "Task 4 completed."
echo ""


# ============================================================
# TASK 5 - ADD MARIA TO DEVELOPERS
# ============================================================

echo "Task 5 - Adding maria to developers..."

usermod -aG developers maria

id maria > "$BASE/task5-maria-groups.txt"

echo "Task 5 completed."
echo ""


# ============================================================
# TASK 6 - ADD ALEX TO APPSUPPORT
# ============================================================

echo "Task 6 - Adding alex to appsupport..."

usermod -aG appsupport alex

id alex > "$BASE/task6-alex-groups.txt"

echo "Task 6 completed."
echo ""


# ============================================================
# TASK 7 - ADD DAVID TO DBADMIN
# ============================================================

echo "Task 7 - Adding david to dbadmin..."

usermod -aG dbadmin david

id david > "$BASE/task7-user-group.txt"

echo "Task 7 completed."
echo ""


# ============================================================
# TASK 8 - REMOVE ALEX FROM APPSUPPORT
# ============================================================

echo "Task 8 - Removing alex from appsupport..."

gpasswd -d alex appsupport

id alex > "$BASE/task8-remove-group.txt"

echo "Task 8 completed."
echo ""


# ============================================================
# TASK 9 - REMOVE MARIA FROM DEVELOPERS
# ============================================================

echo "Task 9 - Removing maria from developers..."

gpasswd -d maria developers

id maria > "$BASE/task9-remove-group.txt"

echo "Task 9 completed."
echo ""


# ============================================================
# TASK 10 - REMOVE DAVID FROM DBADMIN
# ============================================================

echo "Task 10 - Removing david from dbadmin..."

gpasswd -d david dbadmin

id david > "$BASE/task10-remove-group.txt"

echo "Task 10 completed."
echo ""


# ============================================================
# TASK 11 - DELETE GROUPS
# ============================================================

echo "Task 11 - Deleting groups..."

groupdel appsupport
groupdel developers
groupdel dbadmin

{
    getent group appsupport
    getent group developers
    getent group dbadmin
} > "$BASE/task11-delete-groups.txt"

echo "Task 11 completed."
echo ""


# ============================================================
# TASK 12 - DELETE USERS
# ============================================================

echo "Task 12 - Deleting users..."

userdel -r alex
userdel -r david
userdel -r maria

{
    getent passwd alex
    getent passwd david
    getent passwd maria

} > "$BASE/task12-delete-users.txt"

echo "Task 12 completed."
echo ""


# ============================================================
# FINAL OWNERSHIP
# ============================================================

# Give the student ownership of the lab verification files.
chown -R "$STUDENT_NAME:$STUDENT_NAME" "$BASE"


# ============================================================
# COMPLETION
# ============================================================

echo "============================================================"
echo " Lab 219 Completed Successfully"
echo "============================================================"
echo ""
echo "Verification files:"
ls -lh "$BASE"
echo ""
echo "Lab directory: $BASE"
echo "============================================================"
