#!/bin/bash

# Check if running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" >&2
  exit 1
fi

# Function to update the system
function update_system {
  echo "Updating the system..."
  if ! apt update; then
    echo "Failed to update package list." >&2
    exit 1
  fi
  if ! apt upgrade -y; then
    echo "Failed to upgrade the system." >&2
    exit 1
  fi
}

# Function to install necessary packages
function install_packages {
  echo "Installing necessary packages..."
  if ! apt install -y rkhunter clamav clamav-daemon unattended-upgrades deborphan ufw auditd audispd-plugins apparmor apparmor-profiles apparmor-utils; then
    echo "Failed to install necessary packages." >&2
    exit 1
  fi
}

# Other functions (similar pattern)

# Function to configure firewall (ufw)
function configure_firewall {
  echo "Configuring firewall (ufw)..."
  if ! ufw enable; then
    echo "Failed to enable ufw." >&2
    exit 1
  fi
  if ! ufw default deny incoming; then
    echo "Failed to set ufw default policy for incoming traffic." >&2
    exit 1
  fi
  if ! ufw default allow outgoing; then
    echo "Failed to set ufw default policy for outgoing traffic." >&2
    exit 1
  fi
}

# Function to clean up orphaned packages
function cleanup_orphaned_packages {
  echo "Cleaning up orphaned packages..."
  orphaned_packages=$(deborphan)
  if [ -n "$orphaned_packages" ]; then
    echo "$orphaned_packages" | xargs sudo apt remove --purge -y
  else
    echo "No orphaned packages to remove."
  fi
}

# Function to configure periodic checks with rkhunter and ClamAV
function configure_periodic_checks {
  echo "Configuring periodic checks with rkhunter and ClamAV..."
  (crontab -l 2>/dev/null; echo "0 0 * * * root rkhunter --update --propupd --check") | sort -u | crontab -
  (crontab -l 2>/dev/null; echo "0 0 * * * root freshclam && clamscan -r / --exclude-dir=^/sys --exclude-dir=^/dev --exclude-dir=^/proc --exclude-dir=^/run --exclude-dir=^/var/lib/clamav --remove=yes --quiet") | sort -u | crontab -
}

# Updated rest of the functions

# Execute functions
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
echo "Rebooting the system in 30 seconds. Press Ctrl+C to cancel."
sleep 30
reboot
