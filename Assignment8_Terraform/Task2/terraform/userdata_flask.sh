#!/bin/bash

# ============================================================
# Task 2 - Flask Backend User Data Script
# ============================================================

LOG_FILE="/var/log/task2-flask-userdata.log"
DEBUG_LOG_FILE="/var/log/task2-flask-userdata-debug.log"

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
log "Task 2 Flask User Data Script Started"
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
# STEP 6 - Verify Backend Files
# ============================================================

step "Checking Flask backend files"

BACKEND_DIR="$REPO_DIR/Assignment8_Terraform/Task2/backend"

test -f "$BACKEND_DIR/app.py"
test -f "$BACKEND_DIR/requirements.txt"

completed "Flask backend files verified"


# ============================================================
# STEP 7 - Create Python Virtual Environment
# ============================================================

step "Creating Python virtual environment"

VENV_DIR="$BACKEND_DIR/venv"

cd "$BACKEND_DIR"

python3 -m venv "$VENV_DIR"

completed "Python virtual environment"


# ============================================================
# STEP 8 - Verify Virtual Environment
# ============================================================

step "Checking Python virtual environment"

"$VENV_DIR/bin/python" --version
"$VENV_DIR/bin/pip" --version

completed "Python virtual environment verification"


# ============================================================
# STEP 9 - Install Flask Dependencies
# ============================================================

step "Installing Flask backend dependencies"

"$VENV_DIR/bin/pip" install \
    --no-cache-dir \
    -r "$BACKEND_DIR/requirements.txt"

completed "Flask backend dependencies"


# ============================================================
# STEP 10 - Verify Flask
# ============================================================

step "Checking Flask installation"

"$VENV_DIR/bin/python" -c \
    "import flask; print('Flask version:', flask.__version__)"

completed "Flask verification"


# ============================================================
# STEP 11 - Create Flask Startup Script
# ============================================================

step "Creating Flask startup script"

cat > /home/ubuntu/start_flask.sh <<EOF
#!/bin/bash

cd "$BACKEND_DIR"

exec "$VENV_DIR/bin/python" app.py
EOF

chmod +x /home/ubuntu/start_flask.sh

completed "Flask startup script"


# ============================================================
# STEP 12 - Start Flask Backend
# ============================================================

step "Starting Flask backend"

nohup /home/ubuntu/start_flask.sh \
    > /var/log/task2-flask.log 2>&1 &

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
# STEP 13 - Verify Flask Port
# ============================================================

step "Checking Flask port"

if ss -lntp | grep -q ":5000"; then

    log "Port 5000 is listening."

else

    log "Port 5000 is not listening."
    exit 1

fi

completed "Flask port verified"


# ============================================================
# SCRIPT COMPLETE
# ============================================================

log ""
log "============================================================"
log "FLASK BACKEND DEPLOYMENT COMPLETED SUCCESSFULLY"
log "Flask Backend: Port 5000"
log "Flask Log: /var/log/task2-flask.log"
log "Time: $(date)"
log "============================================================"