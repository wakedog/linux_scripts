#!/bin/bash

# Check if running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" >&2
  exit 1
fi

# Function to update the system
function update_system {
  echo "Updating the system..."
  if! apt update && apt upgrade -y; then
    echo "Failed to update the system." >&2
    exit 1
  fi
}

# Function to install necessary packages
function install_packages {
  echo "Installing necessary packages..."
  if! apt install -y rkhunter clamav clamav-daemon unattended-upgrades deborphan; then
    echo "Failed to install necessary packages." >&2
    exit 1
  fi
}

# Function to configure unattended-upgrades
function configure_unattended_upgrades {
  echo "Configuring unattended-upgrades..."
  if! dpkg-reconfigure -plow unattended-upgrades; then
    echo "Failed to configure unattended-upgrades." >&2
    exit 1
  fi
}

# Function to remove bloatware
function remove_bloatware {
  echo "Removing bloatware..."
  if! apt remove --purge -y hexchat thunderbird pidgin transmission-gtk rhythmbox gnome-mahjongg aisleriot; then
    echo "Failed to remove bloatware." >&2
    exit 1
  fi
}

# Function to clean up orphaned packages
function cleanup_orphaned_packages {
  echo "Cleaning up orphaned packages..."
  if! deborphan | xargs sudo apt remove --purge -y; then
    echo "Failed to clean up orphaned packages." >&2
    exit 1
  fi
}

# Function to configure firewall (ufw)
function configure_firewall {
  echo "Configuring firewall (ufw)..."
  if! ufw enable && ufw default deny incoming && ufw default allow outgoing; then
    echo "Failed to configure firewall." >&2
    exit 1
  fi
}

# Function to disable root login
function disable_root_login {
  echo "Disabling root login..."
  if! passwd -l root; then
    echo "Failed to disable root login." >&2
    exit 1
  fi
}

# Function to secure SSH
function secure_ssh {
  echo "Securing SSH..."
  if! sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config \
      && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config \
      && sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config \
      && systemctl restart ssh; then
    echo "Failed to secure SSH." >&2
    exit 1
  fi
}

# Function to configure periodic checks with rkhunter and ClamAV
function configure_periodic_checks {
  echo "Configuring periodic checks with rkhunter and ClamAV..."
  if! echo "0 0 * * * root rkhunter --update --propupd --check" >> /etc/crontab \
      && echo "0 0 * * * root freshclam && clamscan -r / --exclude-dir=^/sys --exclude-dir=^/dev --exclude-dir=^/proc --exclude-dir=^/run --exclude-dir=^/var/lib/clamav --remove=yes --quiet" >> /etc/crontab; then
    echo "Failed to configure periodic checks." >&2
    exit 1
  fi
}

# Function to enable auditing
function enable_auditing {
  echo "Enabling auditing..."
  if! apt install -y auditd audispd-plugins && systemctl enable auditd && systemctl start auditd; then
    echo "Failed to enable auditing." >&2
    exit 1
  fi
}

# Function to apply file permissions and ownership
function set_permissions_ownership {
  echo "Applying file permissions and ownership..."
  if! chown root:root /etc/shadow && chmod 640 /etc/shadow \
      && chown root:root /etc/gshadow && chmod 640 /etc/gshadow; then
    echo "Failed to apply file permissions and ownership." >&2
    exit 1
  fi
}

# Function to enable AppArmor
function enable_apparmor {
  echo "Enabling AppArmor..."
  if! apt install -y apparmor apparmor-profiles apparmor-utils && systemctl enable apparmor && systemctl start apparmor; then
    echo "Failed to enable AppArmor." >&2
    exit 1
  fi
}

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
