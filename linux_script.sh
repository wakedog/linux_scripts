#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Update the system
function update_system {
  apt update && apt upgrade -y
}

# Install necessary packages
function install_packages {
  apt install -y rkhunter clamav clamav-daemon unattended-upgrades deborphan
}

# Configure unattended-upgrades
function configure_unattended_upgrades {
  dpkg-reconfigure -plow unattended-upgrades
}

# Remove bloatware
function remove_bloatware {
  apt remove --purge -y hexchat thunderbird pidgin transmission-gtk rhythmbox gnome-mahjongg aisleriot
}

# Clean up orphaned packages
function cleanup_orphaned_packages {
  deborphan | xargs sudo apt remove --purge -y
}

# Configure firewall (ufw)
function configure_firewall {
  ufw enable
  ufw default deny incoming
  ufw default allow outgoing
}

# Disable root login
function disable_root_login {
  passwd -l root
}

# Secure SSH
function secure_ssh {
  sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
  sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
  systemctl restart ssh
}

# Configure periodic checks with rkhunter and ClamAV
function configure_periodic_checks {
  echo "0 0 * * * root rkhunter --update --propupd --check" >> /etc/crontab
  echo "0 0 * * * root freshclam && clamscan -r / --exclude-dir=^/sys --exclude-dir=^/dev --exclude-dir=^/proc --exclude-dir=^/run --exclude-dir=^/var/lib/clamav --remove=yes --quiet" >> /etc/crontab
}

# Enable auditing
function enable_auditing {
  apt install -y auditd audispd-plugins
  systemctl enable auditd
  systemctl start auditd
}

# Apply file permissions and ownership
function set_permissions_ownership {
  chown root:root /etc/shadow
  chmod 640 /etc/shadow
  chown root:root /etc/gshadow
  chmod 640 /etc/gshadow
}

# Enable AppArmor
function enable_apparmor {
  apt install -y apparmor apparmor-profiles apparmor-utils
  systemctl enable apparmor
  systemctl start apparmor
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
