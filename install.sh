### please do not execute this file directly, examine each command manually before executing. ###

### blacklisting nouveau
# https://docs.nvidia.com/ai-enterprise/deployment-guide-vmware/0.1.0/nouveau.html
cat <<EOF | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
blacklist nouveau
options nouveau modeset=0
EOF
sudo update-initramfs -u
### or alternatively removing it completely
sudo apt-get --purge remove xserver-xorg-video-nouveau && sudo apt-get autoremove

### give the user access to the X server
sudo usermod -aG tty $USER
sudo usermod -aG input $USER

### allow an ssh terminal to start the X server
sudo sed -i 's/console/anybody/g' /etc/X11/Xwrapper.config

### allow every user to get ownership of /dev/tty?
sudo cp control_tty_access /usr/local/sbin/control_tty_access
sudo chmod +x /usr/local/sbin/control_tty_access
echo "ALL ALL=NOPASSWD: /usr/local/sbin/control_tty_access" | sudo tee /etc/sudoers.d/20-control_tty_access
### allow all users to access the colord service
cat <<EOF | sudo tee /etc/polkit-1/localauthority/50-local.d/50-allow-colord.pkla
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

### activate twinview
if [ ! -d "/etc/X11/xorg.conf.d/" ]; then sudo mkdir /etc/X11/xorg.conf.d/; fi
# then either
sudo cp twinview_with_real.conf /etc/X11/xorg.conf.d/20-twinview.conf
# or
sudo cp twinview_just_virtual.conf /etc/X11/xorg.conf.d/20-twinview.conf

# get the busid
# https://askubuntu.com/questions/1062659/ci-bus-id-and-gpu-id
lspci | grep VGA | grep NVIDIA | cut -d' ' -f1
# convert the hex to decimal and set bus id to yours and adjust it
export BUS_ID="PCI:12:0:0" 
sudo sed -i "s/PCI:1:0:0/$BUS_ID/g" /etc/X11/xorg.conf.d/20-twinview.conf
unset BUS_ID

### start ubuntu-flavored gnome
cp .xinitrc ~/.xinitrc
### make it accessible as a service
cp sunshine.service ~/.config/systemd/user/sunshine.service
### copy the executable
sudo cp sunshine_startx /usr/local/bin/sunshine_startx
sudo chmod +x /usr/local/bin/sunshine_startx


# Uninstall
# rm ~/.config/systemd/user/sunshine.service
# sudo rm /etc/X11/xorg.conf.d/20-twinview.conf
# sudo rm /etc/polkit-1/localauthority/50-local.d/50-allow-colord.pkla
# sudo rm /usr/local/sbin/control_tty_access
# sudo rm /etc/sudoers.d/20-control_tty_access
# sudo sed -i 's/anybody/console/g' /etc/X11/Xwrapper.config
