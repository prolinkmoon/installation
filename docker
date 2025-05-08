#!/bin/bash

# =========================================
# Docker Installer Script
# Author: Prolinkmoon
# =========================================

# Terminal Styling
bold=$(tput bold)
normal=$(tput sgr0)
magenta="\033[1;35m"
reset="\033[0m"

msg() {
    local type="$1"
    local text="$2"
    local icon
    case "$type" in
        info) icon="📦";;
        ok) icon="✅";;
        warn) icon="⚠️";;
        err) icon="❌";;
        *) icon="🔹";;
    esac
    echo -e "${magenta}${bold}${icon} ${text}${reset}${normal}"
}

# Function to ask for confirmation
ask_confirmation() {
    local question="$1"
    read -p "$question (y/n): " response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

# Check for curl
ensure_curl() {
    if ! command -v curl >/dev/null; then
        msg info "curl not found. Installing curl..."
        sudo apt update && sudo apt install -y curl || {
            msg err "Failed to install curl. Please install it manually."
            exit 1
        }
    fi
}

# Remove old Docker versions
remove_old_versions() {
    msg info "Removing older Docker versions (if any)..."
    sudo apt remove -y docker docker-engine docker.io containerd runc >/dev/null 2>&1
}

# Install Docker dependencies
install_dependencies() {
    msg info "Installing prerequisites..."
    sudo apt update
    sudo apt install -y ca-certificates curl gnupg lsb-release
}

# Add Docker’s official GPG key
add_docker_gpg() {
    msg info "Adding Docker GPG key..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
}

# Setup Docker repository
setup_repo() {
    msg info "Setting up Docker repository..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
}

# Install Docker Engine
install_docker() {
    msg info "Installing Docker Engine..."
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || {
        msg err "Docker installation failed."
        exit 1
    }
}

# Verify installation
verify_installation() {
    if command -v docker >/dev/null; then
        version=$(docker --version)
        msg ok "Docker installed successfully: $version"
    else
        msg err "Docker not found in PATH after installation."
        exit 1
    fi
}

# Optional: Add user to docker group
add_user_to_docker_group() {
    if ask_confirmation "Do you want to add the current user to the Docker group for passwordless access?"; then
        msg info "Adding current user to docker group..."
        sudo usermod -aG docker "$USER"
        msg ok "Please logout and login again to use Docker without sudo."
    else
        msg info "You can add the user to the Docker group later by running: sudo usermod -aG docker \$USER"
    fi
}

# Main Execution Flow
msg info "Docker installer - Made with Prolinkmoon!"

ensure_curl

if ask_confirmation "Do you want to remove older Docker versions (if any)?"; then
    remove_old_versions
fi

install_dependencies
add_docker_gpg
setup_repo

if ask_confirmation "Do you want to proceed with Docker installation now?"; then
    install_docker
else
    msg info "Installation aborted. You can run this script again when you're ready."
    exit 0
fi

verify_installation

add_user_to_docker_group

msg ok "Docker setup completed! 🐳 You can now use 'docker'."
