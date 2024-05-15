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

# get the busid
# https://askubuntu.com/questions/1062659/ci-bus-id-and-gpu-id
lspci | grep VGA | grep NVIDIA | cut -d' ' -f1

### activate twinview
sudo mkdir /etc/X11/xorg.conf.d/
sudo cp twinview.conf /etc/X11/xorg.conf.d/20-twinview.conf
### start ubuntu-flavored gnome
cp xinitrc ~/.xinitrc
### make it accessible as a service
cp sunshine.service ~/.config/systemd/user/sunshine.service
