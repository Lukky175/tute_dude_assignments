#!/bin/bash

# ============================================================
# Task 2 - Express Frontend User Data Script
# ============================================================

LOG_FILE="/var/log/task2-express-userdata.log"
DEBUG_LOG_FILE="/var/log/task2-express-userdata-debug.log"

touch "$LOG_FILE"
touch "$DEBUG_LOG_FILE"

chmod 644 "$LOG_FILE"
chmod 644 "$DEBUG_LOG_FILE"


# ============================================================
# Redirect complete script output to DEBUG log
# ============================================================

exec > >(tee -a "$DEBUG_LOG_FILE") 2>&1


# ============================================================
# Logging functions
# ============================================================

CURRENT_STEP="Script Initialization"

log() {
    echo "$1" >> "$LOG_FILE"
}

step() {
    CURRENT_STEP="$1"

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
    local failed_command=$2

    failed "$CURRENT_STEP"

    log "Exit Code      : $exit_code"
    log "Line           : $line_number"
    log "Failed Command : $failed_command"

    log ""
    log "Check detailed output here:"
    log "$DEBUG_LOG_FILE"

    exit "$exit_code"
}

trap 'error_handler "$LINENO" "$BASH_COMMAND"' ERR


# ============================================================
# SCRIPT START
# ============================================================

log "============================================================"
log "Task 2 Express User Data Script Started"
log "Time: $(date)"
log "============================================================"


# ============================================================
# STEP 1 - Update system
# ============================================================

step "Updating system packages"

apt-get update -y

completed "System package update"


# ============================================================
# STEP 2 - Install Git
# ============================================================

step "Installing Git"

apt-get install -y git

completed "Git installation"


# ============================================================
# STEP 3 - Install Node.js and npm
# ============================================================

step "Installing Node.js and npm"

apt-get install -y nodejs npm

completed "Node.js and npm installation"


# ============================================================
# STEP 4 - Verify Node.js and npm
# ============================================================

step "Checking Node.js and npm"

node --version
npm --version

completed "Node.js and npm verification"


# ============================================================
# STEP 5 - Clone GitHub repository
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
# STEP 6 - Verify Frontend Files
# ============================================================

step "Checking Express frontend files"

FRONTEND_DIR="$REPO_DIR/Assignment8_Terraform/Task2/frontend"

test -f "$FRONTEND_DIR/server.js"
test -f "$FRONTEND_DIR/package.json"

completed "Express frontend files verified"


# ============================================================
# STEP 7 - Install Express Dependencies
# ============================================================

step "Installing Express frontend dependencies"

cd "$FRONTEND_DIR"

npm install

completed "Express frontend dependencies"


# ============================================================
# STEP 8 - Verify Express
# ============================================================

step "Checking Express installation"

npm list express

completed "Express verification"


# ============================================================
# STEP 9 - Create Express Startup Script
# ============================================================

step "Creating Express startup script"

cat > /home/ubuntu/start_express.sh <<EOF
#!/bin/bash

cd "$FRONTEND_DIR"

exec npm start
EOF

chmod +x /home/ubuntu/start_express.sh

completed "Express startup script"


# ============================================================
# STEP 10 - Start Express Frontend
# ============================================================

step "Starting Express frontend"

nohup /home/ubuntu/start_express.sh \
    > /var/log/task2-express.log 2>&1 &

EXPRESS_PID=$!

log "Express PID: $EXPRESS_PID"

sleep 3

if kill -0 "$EXPRESS_PID" 2>/dev/null; then
    log "Express process is running."
else
    log "Express process failed to start."
    exit 1
fi

completed "Express frontend started on port 3000"


# ============================================================
# STEP 11 - Verify Express Port
# ============================================================

step "Checking Express port"

if ss -lntp | grep -q ":3000"; then
    log "Port 3000 is listening."
else
    log "Port 3000 is not listening."
    exit 1
fi

completed "Express port verified"

# ============================================================
# SCRIPT COMPLETE
# ============================================================

log ""
log "============================================================"
log "EXPRESS FRONTEND DEPLOYMENT COMPLETED SUCCESSFULLY"
log "Express Frontend: Port 3000"
log "Express Log: /var/log/task2-express.log"
log "Time: $(date)"
log "============================================================"