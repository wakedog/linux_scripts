#!/bin/bash

# Variables
LOG_FILE="/var/log/system_hardening_script.log"
CRON_FILE="/etc/crontab"
SSH_CONFIG="/etc/ssh/sshd_config"

# Log function for improved verbosity
function log {
  local MESSAGE="$1"
  echo "$(date +'%Y-%m-%d %H:%M:%S') : $MESSAGE" | tee -a "$LOG_FILE"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
  log "This script must be run as root. Exiting."
  exit 1
fi

# Function to update the system
function update_system {
  log "Updating the system..."
  if ! apt update; then
    log "Failed to update package list."
    exit 1
  fi
  if ! apt upgrade -y; then
    log "Failed to upgrade the system."
  fi
  if ! apt autoremove -y; then
    log "Failed to remove unnecessary packages."
  fi
}

# Function to install necessary packages
function install_packages {
  local PACKAGES=(rkhunter clamav clamav-daemon unattended-upgrades deborphan ufw auditd audispd-plugins apparmor apparmor-profiles apparmor-utils)
  log "Installing necessary packages: ${PACKAGES[*]}..."
  if ! apt install -y "${PACKAGES[@]}"; then
    log "Failed to install necessary packages."
    exit 1
  fi
}

# Function to configure unattended-upgrades
function configure_unattended_upgrades {
  log "Configuring unattended-upgrades..."
  if ! dpkg-reconfigure -plow unattended-upgrades; then
    log "Failed to configure unattended-upgrades."
  fi
}

# Function to remove bloatware
function remove_bloatware {
  local BLOATWARE=(hexchat thunderbird pidgin transmission-gtk rhythmbox gnome-mahjongg aisleriot)
  log "Removing bloatware: ${BLOATWARE[*]}..."
  if ! apt remove --purge -y "${BLOATWARE[@]}"; then
    log "Failed to remove bloatware."
  fi
}

# Function to clean up orphaned packages
function cleanup_orphaned_packages {
  log "Cleaning up orphaned packages..."
  orphaned_packages=$(deborphan)
  if [ -n "$orphaned_packages" ]; then
    if ! echo "$orphaned_packages" | xargs apt remove --purge -y; then
      log "Failed to clean up orphaned packages."
    fi
  else
    log "No orphaned packages to remove."
  fi
}

# Function to configure firewall (ufw)
function configure_firewall {
  log "Configuring firewall (ufw)..."
  if ! ufw enable; then
    log "Failed to enable ufw."
  fi
  if ! ufw default deny incoming; then
    log "Failed to set default deny policy for incoming traffic."
  fi
  if ! ufw default allow outgoing; then
    log "Failed to set default allow policy for outgoing traffic."
  fi
}

# Function to disable root login
function disable_root_login {
  log "Disabling root login..."
  if ! passwd -l root; then
    log "Failed to disable root login."
  fi
}

# Function to secure SSH
function secure_ssh {
  log "Securing SSH configuration..."
  if grep -q "^PermitRootLogin" "$SSH_CONFIG"; then
    sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' "$SSH_CONFIG"
  else
    echo "PermitRootLogin no" >> "$SSH_CONFIG"
  fi

  if grep -q "^PasswordAuthentication" "$SSH_CONFIG"; then
    sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' "$SSH_CONFIG"
  else
    echo "PasswordAuthentication no" >> "$SSH_CONFIG"
  fi

  if grep -q "^#Port 22" "$SSH_CONFIG"; then
    sed -i 's/^#Port 22/Port 2222/' "$SSH_CONFIG"
  elif ! grep -q "^Port" "$SSH_CONFIG"; then
    echo "Port 2222" >> "$SSH_CONFIG"
  fi

  if ! systemctl restart ssh || ! systemctl restart sshd; then
    log "Failed to restart SSH service."
  fi
}

# Function to configure periodic checks with rkhunter and ClamAV
function configure_periodic_checks {
  log "Configuring periodic checks with rkhunter and ClamAV..."
  (crontab -l 2>/dev/null; echo "0 0 * * * root rkhunter --update --propupd --check") | sort -u | crontab -
  (crontab -l 2>/dev/null; echo "0 0 * * * root freshclam && clamscan -r / --exclude-dir=^/sys --exclude-dir=^/dev --exclude-dir=^/proc --exclude-dir=^/run --exclude-dir=^/var/lib/clamav --remove=yes --quiet") | sort -u | crontab -
}

# Function to enable auditing
function enable_auditing {
  log "Enabling auditing..."
  if ! systemctl enable auditd && systemctl start auditd; then
    log "Failed to enable auditing."
  fi
}

# Function to apply file permissions and ownership
function set_permissions_ownership {
  log "Applying file permissions and ownership..."
  if ! chown root:root /etc/shadow && chmod 600 /etc/shadow; then
    log "Failed to set permissions on /etc/shadow."
  fi
  if ! chown root:root /etc/gshadow && chmod 640 /etc/gshadow; then
    log "Failed to set permissions on /etc/gshadow."
  fi
}

# Function to enable AppArmor
function enable_apparmor {
  log "Enabling AppArmor..."
  if ! systemctl enable apparmor && systemctl start apparmor; then
    log "Failed to enable AppArmor."
  fi
}

# Execute functions in sequence
update_system
install_packages
configure_unattended_upgrades
remove_bloatware
cleanup_orphaned_packages
configure_firewall
disable_root_login
secure_ssh
configure_periodic_checks
enable_auditing
set_permissions_ownership
enable_apparmor

# Reboot the system
log "Rebooting the system in 30 seconds. Press Ctrl+C to cancel."
sleep 30
reboot
