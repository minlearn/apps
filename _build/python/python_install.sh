###############

silent() { "$@" >/dev/null 2>&1; }

echo "Installing Dependencies"
silent apt-get install -y curl sudo mc
echo "Installed Dependencies"

echo "Installing Python Dependencies"
silent apt-get -y install python3-pip
rm -rf /usr/lib/python3.*/EXTERNALLY-MANAGED
echo "Installed Python Dependencies"

echo "Cleaning up"
silent apt-get -y autoremove
silent apt-get -y autoclean
echo "Cleaned"

##############
