#!/bin/bash
# Configure MSI GS63 7RE Stealth Pro as a server (Ubuntu)
# Run with: sudo bash configure_msi_server.sh

echo "Configuring laptop to ignore lid close events..."

# 1. Configure systemd-logind to ignore lid switch
sed -i 's/^#HandleLidSwitch=.*/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
sed -i 's/^HandleLidSwitch=.*/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
sed -i 's/^#HandleLidSwitchExternalPower=.*/HandleLidSwitchExternalPower=ignore/' /etc/systemd/logind.conf
sed -i 's/^HandleLidSwitchExternalPower=.*/HandleLidSwitchExternalPower=ignore/' /etc/systemd/logind.conf
sed -i 's/^#HandleLidSwitchDocked=.*/HandleLidSwitchDocked=ignore/' /etc/systemd/logind.conf
sed -i 's/^HandleLidSwitchDocked=.*/HandleLidSwitchDocked=ignore/' /etc/systemd/logind.conf

# Add lines if they don't exist
grep -q "^HandleLidSwitch=" /etc/systemd/logind.conf || echo "HandleLidSwitch=ignore" >> /etc/systemd/logind.conf
grep -q "^HandleLidSwitchExternalPower=" /etc/systemd/logind.conf || echo "HandleLidSwitchExternalPower=ignore" >> /etc/systemd/logind.conf
grep -q "^HandleLidSwitchDocked=" /etc/systemd/logind.conf || echo "HandleLidSwitchDocked=ignore" >> /etc/systemd/logind.conf

echo "Disabling automatic suspend and hibernation..."

# 2. Disable automatic suspend
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

echo "Configuration complete!"
echo "Please restart systemd-logind: sudo systemctl restart systemd-logind"
echo "Or reboot the system for changes to take full effect."
echo ""
echo "To verify settings:"
echo "  cat /etc/systemd/logind.conf | grep HandleLid"
