This project provides a script to automate various tasks for hardening the security of a Linux system. The script performs the following tasks:

    Update System: Ensures that the system is up-to-date with the latest security patches.
    
    Install Packages: Installs essential security packages.
    
    Configure Unattended Upgrades: Sets up automatic security updates to minimize vulnerabilities.
    
    Remove Bloatware: Removes unnecessary and potentially insecure software.
    
    Cleanup Orphaned Packages: Deletes unused and orphaned packages to reduce attack surface.
    
    Configure Firewall: Sets up and configures a firewall to protect the system from unauthorized access.
    
    Disable Root Login: Disables direct root login to prevent unauthorized access.
    
    Secure SSH: Enhances SSH security by applying best practices and hardening configurations.
    
    Configure Periodic Checks: Sets up regular system checks to monitor for potential security issues.
    
    Enable Auditing: Activates system auditing to track and log security-related events.
    
    Set Permissions & Ownership: Adjusts file permissions and ownership to minimize security risks.
    
    Enable AppArmor: Activates AppArmor, a mandatory access control (MAC) system to enforce security policies.
    

Usage

To use the security hardening script, follow these steps:

Clone this repository to your local machine: git clone https://github.com/wakedog/linux_script.sh

Navigate to the cloned repository with cd (Change Directory)

Make the script executable: chmod +x linux_script.sh

Run the script as root or with sudo privileges: sudo ./linux_script.sh


Resources

To learn more about security hardening and relevant regulations, visit the following sites:

    Defense Information Systems Agency (DISA)
    National Security Agency (NSA)
    National Institute of Standards and Technology (NIST) - Security Technical Implementation Guides (STIGs)

Please ensure to comply with your organization's security policies and any applicable regulations when using this script.
