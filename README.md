# System Hardening Script

## Overview

This script is designed to enhance the security of an Ubuntu system by performing several system-hardening tasks. It ensures that important security settings are configured, unnecessary packages are removed, and the system is prepared to run securely in a production environment.

The script includes functions for updating the system, installing necessary packages, securing SSH, configuring firewalls, enabling auditing, and other critical hardening measures. Logs are maintained for each action to provide visibility into the steps performed.

### Features
- Updates and upgrades system packages
- Installs essential security tools (`rkhunter`, `clamav`, `ufw`, `auditd`, etc.)
- Configures unattended upgrades to automatically apply updates
- Removes unnecessary/bloatware packages
- Sets up and configures a firewall (UFW)
- Disables root login and secures SSH configuration
- Sets up periodic scans with `rkhunter` and `ClamAV`
- Enables auditing (`auditd`) for system monitoring
- Configures proper permissions for sensitive system files
- Enables `AppArmor` for additional security enforcement

## Prerequisites

- **Root privileges**: The script must be run as root to make system-level changes.
- **Supported OS**: This script is designed for Ubuntu systems. Ensure your environment matches the dependencies specified in the script.

## Usage

1. **Clone the Repository**: First, clone the GitHub repository containing the script.
   ```sh
   git clone https://github.com/yourusername/system-hardening-script.git
   cd system-hardening-script
   ```

2. **Make the Script Executable**: Grant execute permissions to the script.
   ```sh
   chmod +x system_hardening_script.sh
   ```

3. **Run the Script**: Execute the script with root privileges.
   ```sh
   sudo ./system_hardening_script.sh
   ```

4. **Monitor Logs**: The script logs its actions to `/var/log/system_hardening_script.log`. You can check this file to see the detailed actions and results of each step.
   ```sh
   cat /var/log/system_hardening_script.log
   ```

## Script Details

The script performs the following tasks step-by-step:

1. **System Update and Upgrade**: Updates the package list, upgrades all installed packages, and removes obsolete packages.

2. **Install Necessary Packages**: Installs key security and monitoring tools such as `rkhunter`, `ClamAV`, `unattended-upgrades`, `ufw`, `auditd`, and `AppArmor`.

3. **Configure Unattended Upgrades**: Sets up the system to automatically install security updates.

4. **Remove Bloatware**: Removes commonly unnecessary packages like `hexchat`, `thunderbird`, `pidgin`, etc.

5. **Clean Up Orphaned Packages**: Uses `deborphan` to identify and remove orphaned packages.

6. **Configure Firewall (UFW)**: Enables UFW, sets up default rules to deny incoming connections, and allows outgoing traffic.

7. **Disable Root Login**: Disables root login to prevent unauthorized direct root access.

8. **Secure SSH**: Updates SSH settings to:
   - Disallow root login (`PermitRootLogin no`)
   - Disable password authentication (`PasswordAuthentication no`)
   - Change the default SSH port to 2222

9. **Configure Periodic Checks**: Sets up cron jobs for regular `rkhunter` and `ClamAV` scans to detect rootkits and malware.

10. **Enable Auditing**: Enables and starts `auditd` for auditing system activities.

11. **Set File Permissions and Ownership**: Sets proper permissions for sensitive files like `/etc/shadow` and `/etc/gshadow` to prevent unauthorized access.

12. **Enable AppArmor**: Starts and enables `AppArmor` for application-level security enforcement.

13. **Reboot**: Reboots the system after a 30-second delay to apply certain changes.

## Notes

- **SSH Configuration**: After running this script, the SSH service will use port 2222 instead of the default port 22. You will need to adjust your SSH client settings accordingly:
  ```sh
  ssh -p 2222 user@your-server-ip
  ```

- **Firewall Settings**: The script uses `ufw` to enforce a default deny-all incoming policy and allow-all outgoing traffic. Make sure to modify these rules based on your specific requirements.

- **Cron Jobs**: The script configures cron jobs for daily security checks. To view or modify these cron jobs, edit `/etc/crontab` or use `crontab -e`.

## Important Warnings

- **Run As Root**: The script must be executed as root. Failure to do so will result in errors for tasks that require administrative privileges.
- **Impact on Services**: The script modifies critical system files, disables root login, and changes the SSH port. Ensure you understand the impact on your environment before running it.
- **Bloatware Removal**: The script removes some packages considered bloatware. If you need any of these applications, adjust the `remove_bloatware` function accordingly.

## Customization

Feel free to modify the script to better fit your environment:
- **Package List**: Add or remove packages to suit your needs.
- **Firewall Rules**: Update the UFW rules to reflect your specific network security policies.
- **SSH Settings**: Change SSH settings as per your security requirements.

## License

This script is open-source and available under the MIT License. Feel free to modify and distribute as needed.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your improvements or suggestions.

## Support

If you encounter any issues or have questions about the script, please open an issue on GitHub, and we'll do our best to assist.
