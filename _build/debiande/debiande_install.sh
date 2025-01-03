###############

silent() { "$@" >/dev/null 2>&1; }

echo "Installing Dependencies"
silent apt-get install -y curl sudo mc
echo "Installed Dependencies"

echo "installing x11 supports"
silent apt-get install --no-install-recommends debconf-utils -y
echo keyboard-configuration  keyboard-configuration/unsupported_config_options       boolean true | debconf-set-selections >/dev/null 2>&1; \
echo keyboard-configuration  keyboard-configuration/switch   select  No temporary switch | debconf-set-selections >/dev/null 2>&1; \
echo keyboard-configuration  keyboard-configuration/unsupported_config_layout        boolean true | debconf-set-selections >/dev/null 2>&1; \
echo keyboard-configuration  keyboard-configuration/layoutcode       string  us | debconf-set-selections >/dev/null 2>&1; \
echo keyboard-configuration  keyboard-configuration/compose  select  No compose key | debconf-set-selections >/dev/null 2>&1; \
echo keyboard-configuration  keyboard-configuration/modelcode        string  pc105 | debconf-set-selections >/dev/null 2>&1; \
echo keyboard-configuration  keyboard-configuration/unsupported_options      boolean true | debconf-set-selections >/dev/null 2>&1; \
echo keyboard-configuration  keyboard-configuration/variant  select  English \(US\) | debconf-set-selections >/dev/null 2>&1; \
echo keyboard-configuration  keyboard-configuration/unsupported_layout       boolean true | debconf-set-selections >/dev/null 2>&1; \
echo keyboard-configuration  keyboard-configuration/model    select  Generic 105-key PC \(intl.\) | debconf-set-selections >/dev/null 2>&1; \
echo keyboard-configuration  keyboard-configuration/ctrl_alt_bksp    boolean false | debconf-set-selections >/dev/null 2>&1; \
echo keyboard-configuration  keyboard-configuration/layout   select | debconf-set-selections >/dev/null 2>&1; \
echo keyboard-configuration  keyboard-configuration/toggle   select  No toggling | debconf-set-selections >/dev/null 2>&1; \
echo keyboard-configuration  keyboard-configuration/variantcode      string | debconf-set-selections >/dev/null 2>&1; \
echo keyboard-configuration  keyboard-configuration/altgr    select  The default for the keyboard layout | debconf-set-selections >/dev/null 2>&1; \
echo keyboard-configuration  keyboard-configuration/xkb-keymap       select  us | debconf-set-selections >/dev/null 2>&1; \
echo keyboard-configuration  keyboard-configuration/optionscode      string | debconf-set-selections >/dev/null 2>&1; \
echo keyboard-configuration  keyboard-configuration/store_defaults_in_debconf_db     boolean true | debconf-set-selections >/dev/null 2>&1

silent apt-get install --no-install-recommends keyboard-configuration xserver-xorg xinit xterm -y
silent apt-get install --no-install-recommends xserver-xorg-video-dummy gnome-session lightdm dbus-x11 x11vnc -y

chmod u+s /usr/lib/xorg/Xorg
touch /home/tdl/.Xauthority /root/.Xauthority

cat >/usr/share/X11/xorg.conf.d/20-dummyx11.conf<<EOF
# This xorg configuration file is meant to be used
# to start a dummy X11 server.
# For details, please see:
# https://www.xpra.org/xorg.conf

# Here we setup a Virtual Display of 1600x900 pixels

Section "Device"
	Identifier "Configured Video Device"
	Driver "dummy"
	# VideoRam 4096000
	# VideoRam 256000
	VideoRam 16384
EndSection

Section "Monitor"
	Identifier "Configured Monitor"
	HorizSync 5.0 - 1000.0
	VertRefresh 5.0 - 200.0
	Modeline "1600x900" 33.92 1600 1632 1760 1792 900 921 924 946
EndSection

Section "Screen"
	Identifier "Default Screen"
	Monitor "Configured Monitor"
	Device "Configured Video Device"
	DefaultDepth 24
	SubSection "Display"
		Viewport 0 0
		Depth 24
		Virtual 1600 900
	EndSubSection
EndSection
EOF

echo "setup all graphics services"
x11vnc -storepasswd tdl /etc/x11vnc.pwd >/dev/null 2>&1
echo -e '[Unit]\nDescription=Remote desktop service (VNC)\nRequires=lightdm.service\nAfter=lightdm.service\n\n[Service]\nType=forking\nExecStart=/usr/bin/x11vnc -display :0 -forever -shared -bg -auth /var/run/lightdm/root/:0 -rfbauth /etc/x11vnc.pwd -o /var/log/x11vnc.log\nExecStop=/usr/bin/killall x11vnc\nRestart=on-failure\nRestartSec=5\n\n[Install]\nWantedBy=multi-user.target' > /usr/lib/systemd/system/vnc.service
systemctl enable vnc.service >/dev/null 2>&1
systemctl start vnc.service >/dev/null 2>&1

echo "Cleaning up"
silent apt-get -y autoremove
silent apt-get -y autoclean
echo "Cleaned"

##############
