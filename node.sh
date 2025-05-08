#!/bin/bash

# ============================
# Node.js Installer Script
# By: Prolinkmoon :)
# ============================

# Styling
bold=$(tput bold)
normal=$(tput sgr0)
purple="\033[1;35m"
reset="\033[0m"

log() {
    local type="$1"
    local message="$2"
    local icon=""
    case "$type" in
        info) icon="🔍";;
        ok) icon="✅";;
        warn) icon="⚠️";;
        err) icon="❌";;
        *) icon="ℹ️";;
    esac
    echo -e "${purple}${bold}${icon} ${message}${reset}${normal}"
}

# Check dependency: curl
check_curl() {
    if ! command -v curl &>/dev/null; then
        log info "curl not found, installing..."
        sudo apt update && sudo apt install -y curl || {
            log err "Unable to install curl. Please install it manually."
            exit 1
        }
    fi
}

# Get latest Node.js LTS version
fetch_latest_node_version() {
    local version=$(curl -s https://nodejs.org/dist/index.tab | awk '/^v/ && /LTS/ { print $1; exit }' | sed 's/^v//')
    if [[ -z "$version" ]]; then
        log warn "Failed to fetch latest version. Falling back to v20."
        echo "20"
    else
        echo "$version"
    fi
}

# Setup NodeSource
setup_nodesource() {
    local major="$1"
    local setup_url="https://deb.nodesource.com/setup_${major}.x"
    log info "Preparing NodeSource for Node.js v${major}.x..."

    local tmpfile
    tmpfile=$(mktemp)

    if curl -fsSL "$setup_url" -o "$tmpfile"; then
        if grep -q "<html>" "$tmpfile"; then
            log warn "Invalid script received. Trying fallback installation."
            return 1
        fi
        sudo bash "$tmpfile" && rm -f "$tmpfile"
        return $?
    else
        log err "Download failed for setup script."
        rm -f "$tmpfile"
        return 1
    fi
}

# Install Node.js using alternative way
install_node_alternative() {
    log info "Using manual repo setup for Node.js..."
    sudo apt install -y ca-certificates gnupg
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${1}.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list > /dev/null
    sudo apt update && sudo apt install -y nodejs
}

# Main
check_curl

if command -v node &>/dev/null; then
    log warn "Node.js already exists at $(which node). Continuing with installation to update..."
fi

VERSION=$(fetch_latest_node_version)
MAJOR=$(echo "$VERSION" | cut -d. -f1)

if ! setup_nodesource "$MAJOR"; then
    install_node_alternative "$MAJOR"
fi

# Verify
if command -v node &>/dev/null && command -v npm &>/dev/null; then
    NODE_VER=$(node -v)
    NPM_VER=$(npm -v)
    log ok "Node.js $NODE_VER and npm $NPM_VER are ready to use."
else
    log err "Installation succeeded but binaries not found in PATH."
    echo "Try restarting your terminal or check your \$PATH."
    exit 1
fi

log ok "All set! Happy hacking 🚀"
