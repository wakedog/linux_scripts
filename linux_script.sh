#!/bin/bash

# ASCII art banner
echo "
   __  __  __  __  __  __  __ 
  /  \/  \/  \/  \/  \/  \/  \
 ( W   A   K   E   D   O   G )
  \__/\__/\__/\__/\__/\__/\__/
"

# Create a function to prompt the user for confirmation before executing a block of code
function ConfirmExecution() {
    read -p "$1 (Y/N)" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# 1. Harden the system by enabling built-in security features
# 1.1 Enable the firewall
if !(ufw status | grep -q "active"); then
    if ConfirmExecution "Do you want to enable the firewall?"; then
        ufw enable
    fi
fi

# 1.2 Enable automatic security updates
if !(grep "APT::Periodic::Update-Package-Lists" /etc/apt/apt.conf.d/10periodic | grep -q "1"); then
    if ConfirmExecution "Do you want to enable automatic security updates?"; then
        # Set the update frequency to daily
        sed -i "s/APT::Periodic::Update-Package-Lists \"0\"/APT::Periodic::Update-Package-Lists \"1\"/g" /etc/apt/apt.conf.d/10periodic
    fi
fi

# 1.3 Enable strong passwords
if !(grep "pam_pwquality.so" /etc/pam.d/common-password | grep -q "minlen=8"); then
    if ConfirmExecution "Do you want to enable strong passwords (minimum length 8 characters)?"; then
        # Set the minimum password length to 8 characters
        sed -i "s/pam_pwquality.so/pam_pwquality.so minlen=8/g" /etc/pam.d/common-password
    fi
fi

# 2.1 Remove harmful software (e.g. malware, adware)
if ConfirmExecution "Do you want to scan for and remove harmful software?"; then
    # Use ClamAV to scan for and remove harmful software
    sudo freshclam
    sudo clamscan --remove --recursive /
fi

# 3. Debloat the system by removing unnecessary features and components
# 3.1 Remove unnecessary Ubuntu features and components
if ConfirmExecution "Do you want to remove unnecessary Ubuntu features and components?"; then
    # List of unnecessary features and components can be customized to suit the user's needs
    # Example: remove Amazon, LibreOffice, and Shotwell
    sudo apt-get purge ubuntu-web-launchers libreoffice-core shotwell
fi

# 3.2 Remove bloatware (i.e. pre-installed manufacturer software)
if ConfirmExecution "Do you want to remove bloatware?"; then
    # List of bloatware can be customized to suit the user's needs
    # Example: remove Candy Crush, Farmville, and other Snap Store games
    sudo snap remove candy-crush
    sudo snap remove farmville
    sudo snap remove spaceteam
    sudo snap remove a-dark-room
    sudo snap remove ibooks
    sudo snap remove pixelmator
    sudo snap remove garageband
    sudo snap remove xcode
fi

# 4. Customize system settings to improve security and performance
# 4.1 Enable automatic updates
if !(grep "Unattended-Upgrade::Automatic-Reboot" /etc/apt/apt.conf.d/50unattended-upgrades | grep -q "true"); then
    if ConfirmExecution "Do you want to enable automatic updates?"; then
        # Enable automatic updates and reboot
        sed -i "s/Unattended-Upgrade::Automatic-Reboot \"false\"/Unattended-Upgrade::Automatic-Reboot \"true\"/g" /etc/apt/apt.conf.d/50unattended-upgrades
    fi
fi

# 4.2 Enable automatic security updates
if !(grep "APT::Periodic::Unattended-Upgrade" /etc/apt/apt.conf.d/10periodic | grep -q "1"); then
    if ConfirmExecution "Do you want to enable automatic security updates?"; then
        # Set the update frequency to daily
        sed -i "s/APT::Periodic::Unattended-Upgrade \"0\"/APT::Periodic::Unattended-Upgrade \"1\"/g" /etc/apt/apt.conf.d/10periodic
    fi
fi

# 5. Optimize system performance
# 5.1 Defragment hard drive
if ConfirmExecution "Do you want to defragment the hard drive?"; then
    # Choose the hard drive to defragment (e.g. /dev/sda)
    read -p "Enter the hard drive to defragment (e.g. /dev/sda): " hardDrive
    sudo e4defrag "$hardDrive"
fi

# 5.2 Clear temporary files
if ConfirmExecution "Do you want to clear temporary files?"; then
    sudo rm -rf /tmp/*
    sudo rm -rf /var/tmp/*
fi

# 5.3 Disable unnecessary services
if ConfirmExecution "Do you want to disable unnecessary services?"; then
    # List of unnecessary services can be customized to suit the user's needs
    # Example: disable print spooler service if there are no printers installed
    if [[ $(lpstat -p | wc -l) -eq 0 ]]; then
        sudo systemctl disable cups
        sudo systemctl stop cups
    fi
fi

# 6. Perform a system backup
if ConfirmExecution "Do you want to perform a system backup?"; then
    # Choose a backup location (e.g. external hard drive, network share)
    read -p "Enter the backup location (e.g. /media/backup): " backupLocation
    # Set the date and time as the backup folder name
    dateTime=$(date +%Y-%m-%d_%H-%M-%S)
    backupFolder="$backupLocation/$dateTime"
    # Create the backup folder
    mkdir "$backupFolder"
    # Perform the backup using the built-in Deja Dup tool
    deja-dup --backup --folder "$backupFolder"
fi

# 7. Restart the system
if ConfirmExecution "Do you want to restart the system now?"; then
    sudo shutdown -r now
fi