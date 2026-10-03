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
# STEP 9 - Define Application Directories
# ============================================================

step "Configuring application directories"

BACKEND_DIR="$REPO_DIR/Assignment8_Terraform/Task1/backend"
FRONTEND_DIR="$REPO_DIR/Assignment8_Terraform/Task1/frontend"

VENV_DIR="$BACKEND_DIR/venv"

log "Backend directory : $BACKEND_DIR"
log "Frontend directory: $FRONTEND_DIR"
log "Virtual environment: $VENV_DIR"

completed "Application directories configured"


# ============================================================
# STEP 10 - Verify Backend and Frontend
# ============================================================

step "Checking application files"

test -f "$BACKEND_DIR/app.py"
test -f "$BACKEND_DIR/requirements.txt"

test -f "$FRONTEND_DIR/server.js"
test -f "$FRONTEND_DIR/package.json"

completed "Application files verified"


# ============================================================
# STEP 11 - Create Python Virtual Environment
# ============================================================

step "Creating Python virtual environment"

cd "$BACKEND_DIR"

python3 -m venv "$VENV_DIR"

completed "Python virtual environment"


# ============================================================
# STEP 12 - Verify Virtual Environment
# ============================================================

step "Checking Python virtual environment"

"$VENV_DIR/bin/python" --version
"$VENV_DIR/bin/pip" --version

completed "Python virtual environment verification"


# ============================================================
# STEP 13 - Install Flask Backend Dependencies
# ============================================================

step "Installing Flask backend dependencies"

"$VENV_DIR/bin/pip" install --no-cache-dir -r "$BACKEND_DIR/requirements.txt"

completed "Flask backend dependencies"


# ============================================================
# STEP 14 - Verify Flask Installation
# ============================================================

step "Checking Flask installation"

"$VENV_DIR/bin/python" -c "import flask; print('Flask version:', flask.__version__)"

completed "Flask verification"


# ============================================================
# STEP 15 - Install Express Frontend Dependencies
# ============================================================

step "Installing Express frontend dependencies"

cd "$FRONTEND_DIR"

npm install

completed "Express frontend dependencies"


# ============================================================
# STEP 16 - Verify Express Installation
# ============================================================

step "Checking Express installation"

npm list express

completed "Express verification"


# ============================================================
# STEP 17 - Create Flask Startup Script
# ============================================================

step "Creating Flask startup script"

cat > /home/ubuntu/start_backend.sh <<EOF
#!/bin/bash

cd "$BACKEND_DIR"

exec "$VENV_DIR/bin/python" app.py
EOF

chmod +x /home/ubuntu/start_backend.sh

completed "Flask startup script"


# ============================================================
# STEP 18 - Create Express Startup Script
# ============================================================

step "Creating Express startup script"

cat > /home/ubuntu/start_frontend.sh <<EOF
#!/bin/bash

cd "$FRONTEND_DIR"

exec npm start
EOF

chmod +x /home/ubuntu/start_frontend.sh

completed "Express startup script"


# ============================================================
# STEP 19 - Start Flask Backend
# ============================================================

step "Starting Flask backend"

nohup /home/ubuntu/start_backend.sh \
    > /var/log/task1-flask.log 2>&1 &

FLASK_PID=$!

log "Flask PID: $FLASK_PID"

sleep 3

if kill -0 "$FLASK_PID" 2>/dev/null; then
    log "Flask process is running."
else
    log "Flask process failed to start."
    exit 1
fi

completed "Flask backend started on port 5000"


# ============================================================
# STEP 20 - Start Express Frontend
# ============================================================

step "Starting Express frontend"

nohup /home/ubuntu/start_frontend.sh \
    > /var/log/task1-express.log 2>&1 &

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
# STEP 21 - Verify Listening Ports
# ============================================================

step "Checking application ports"

if ss -lntp | grep -q ":5000"; then
    log "Port 5000 is listening."
else
    log "Port 5000 is not listening."
    exit 1
fi

if ss -lntp | grep -q ":3000"; then
    log "Port 3000 is listening."
else
    log "Port 3000 is not listening."
    exit 1
fi

completed "Application ports verified"


# ============================================================
# STEP 22 - Final Status
# ============================================================

step "Final application status"

log "Flask Backend : http://0.0.0.0:5000"
log "Express Frontend: http://0.0.0.0:3000"

log ""
log "Flask log:"
log "/var/log/task1-flask.log"

log "Express log:"
log "/var/log/task1-express.log"

completed "Final application status"


# ============================================================
# SCRIPT COMPLETE
# ============================================================

log ""
log "============================================================"
log "ALL USER DATA STEPS COMPLETED SUCCESSFULLY"
log "============================================================"
log "Task 1 applications are running."
log "Flask  : Port 5000"
log "Express: Port 3000"
log "Time: $(date)"
log "============================================================"