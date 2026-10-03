#!/bin/bash

# ============================================================
# Task 1 - EC2 User Data Script
# Flask Backend + Express Frontend
# ============================================================

LOG_FILE="/var/log/task1-userdata.log"
DEBUG_LOG_FILE="/var/log/task1-userdata-debug.log"

touch "$LOG_FILE"
touch "$DEBUG_LOG_FILE"

chmod 644 "$LOG_FILE"
chmod 644 "$DEBUG_LOG_FILE"

# ------------------------------------------------------------
# Redirect complete script output to DEBUG log
# ------------------------------------------------------------

exec > >(tee -a "$DEBUG_LOG_FILE") 2>&1


# ============================================================
# Logging functions
# ============================================================

log() {
    echo "$1" >> "$LOG_FILE"
}

step() {
    log ""
    log "============================================================"
    log "STARTED: $1"
    log "Time: $(date)"
    log "============================================================"
}

completed() {
    log "COMPLETED: $1"
    log "Time: $(date)"
}

failed() {
    log ""
    log "============================================================"
    log "FAILED: $1"
    log "Time: $(date)"
    log "============================================================"
}


# ============================================================
# Error handling
# ============================================================

set -E

error_handler() {

    local exit_code=$?
    local line_number=$1

    failed "User Data Script"

    log "Exit Code : $exit_code"
    log "Line      : $line_number"

    log ""
    log "Check detailed output here:"
    log "$DEBUG_LOG_FILE"

    exit "$exit_code"
}

trap 'error_handler $LINENO' ERR


# ============================================================
# SCRIPT START
# ============================================================

log "============================================================"
log "Task 1 User Data Script Started"
log "Time: $(date)"
log "============================================================"


# ============================================================
# STEP 1 - Update system
# ============================================================

step "Updating system packages"

apt-get update -y

completed "System package update"


# ============================================================
# STEP 2 - Install Python
# ============================================================

step "Installing Python"

apt-get install -y \
    python3 \
    python3-pip \
    python3-venv

completed "Python installation"


# ============================================================
# STEP 3 - Verify Python
# ============================================================

step "Checking Python installation"

python3 --version
pip3 --version

completed "Python verification"


# ============================================================
# STEP 4 - Install Git
# ============================================================

step "Installing Git"

apt-get install -y git

completed "Git installation"


# ============================================================
# STEP 5 - Install Node.js and npm
# ============================================================

step "Installing Node.js and npm"

apt-get install -y nodejs npm

completed "Node.js and npm installation"


# ============================================================
# STEP 6 - Verify Node.js and npm
# ============================================================

step "Checking Node.js and npm"

node --version
npm --version

completed "Node.js and npm verification"


# ============================================================
# STEP 7 - Clone GitHub repository
# ============================================================

step "Cloning GitHub repository"

REPO_URL="https://github.com/Lukky175/tute_dude_assignments.git"
REPO_DIR="/home/ubuntu/tute_dude_assignments"

if [ -d "$REPO_DIR/.git" ]; then

    log "Repository already exists."
    log "Skipping clone."

else

    git clone "$REPO_URL" "$REPO_DIR"

fi

completed "GitHub repository"


# ============================================================
# STEP 8 - Verify repository
# ============================================================

step "Checking repository"

ls -la "$REPO_DIR"

completed "Repository verification"


# ============================================================
# SCRIPT COMPLETE
# ============================================================

log ""
log "============================================================"
log "ALL USER DATA STEPS COMPLETED SUCCESSFULLY"
log "Time: $(date)"
log "============================================================"