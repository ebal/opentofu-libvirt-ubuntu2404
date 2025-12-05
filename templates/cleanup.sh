# cleanup.sh - Script to remove old kernels and unnecessary packages

# Clean up apt cache and unnecessary packages
apt-get -y autoremove --purge 
apt -y autoclean
apt -y clean all
rm -rf /usr/share/doc/*

# Remove Snap and LXC/LXD
apt-get -y autoremove --purge lxc lxd snapd lxd-agent-loader lxd-installer

# Remove old Linux kernels
dpkg -l 'linux-image-[0-9]*' | awk '/^ii/ {print $2}' | grep -v $(uname -r) | xargs -r apt-get -y autoremove --purge

# cloud-init cleanup
cloud-init clean --logs
rm -rf /var/lib/cloud/
rm -rf /etc/cloud/

# Final step of cloud-init
# apt-get -y autoremove --purge cloud-init
