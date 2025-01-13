###############

echo "Installing Dependencies"

silent() { "$@" >/dev/null 2>&1; }

silent apt-get install -y curl sudo mc
echo "Installed Dependencies"

get_latest_release() {
  curl -sL https://api.github.com/repos/$1/releases/latest | grep '"tag_name":' | cut -d'"' -f4
}

DOCKER_LATEST_VERSION=$(get_latest_release "moby/moby")
echo "Installing Docker $DOCKER_LATEST_VERSION"
DOCKER_CONFIG_PATH='/etc/docker/daemon.json'
mkdir -p $(dirname $DOCKER_CONFIG_PATH)
echo -e '{\n  "log-driver": "journald"\n}' >/etc/docker/daemon.json
silent sh <(curl -sSL https://get.docker.com)
echo "Installed Docker $DOCKER_LATEST_VERSION"

for i in ashmem:61 binder:60 hwbinder:59 vndbinder:58;do
  if [ ! -e /dev/${i%%:*} ]; then
    mknod /dev/${i%%:*} c 10 ${i##*:}
    chmod 777 /dev/${i%%:*}
    #chown root:${i%%:*} /dev/${i%%:*}
  fi
done

cd /root


wget https://raw.githubusercontent.com/minlearn/appp/master/_build/redriod/data.tar.gz -O data.tar.gz
tar zxf data.tar.gz

tee -a reconnect.sh > /dev/null <<EOF
REDROID="android-redroid8"
SCRCPY="android-scrcpy-web"
NGINX="android-nginx"
docker exec -it \${SCRCPY} adb connect \${REDROID}:5555
EOF
chmod +x ./reconnect.sh

tee -a start.sh > /dev/null <<EOF
REDROID="android-redroid8"
SCRCPY="android-scrcpy-web"
NGINX="android-nginx"

echo -e "\n 1.create \${REDROID}"
docker run -itd --name=\${REDROID} \
    --restart=always \
    --memory-swappiness=0 \
    --privileged --pull always \
    -v ./data/redroid/data:/data \
    redroid/redroid:12.0.0_64only-latest \
    androidboot.hardware=mt6891 ro.secure=0 ro.boot.hwc=GLOBAL    ro.ril.oem.imei=861503068361145 ro.ril.oem.imei1=861503068361145 ro.ril.oem.imei2=861503068361148 ro.ril.miui.imei0=861503068361148 ro.product.manufacturer=Xiaomi ro.build.product=chopin \
    redroid.width=720 redroid.height=1280 \
    redroid.gpu.mode=guest

echo -e "\n 2.create android:scrcpy-web "
docker run -itd --restart=always --privileged -v ./data/scrcpy-web/data:/data -v ./data/scrcpy-web/apk:/apk --name \${SCRCPY} --link \${REDROID} emptysuns/scrcpy-web:v0.1

sleep 3
echo -e "\n 3.\${SCRCPY} adb connect \${REDROID}"
while [ 0 = 0 ]; do
  if docker exec -it \${SCRCPY} adb get-state 1>/dev/null 2>&1; then
    echo "Host found"
    break
  else
    echo "modules lost?"
    docker exec -it \${SCRCPY} adb connect \${REDROID}:5555
  fi
  sleep 5
done

echo -e "\n 4.create android:nginx"
docker run -itd --restart=always -v ./data/nginx/nginx.conf:/etc/nginx/nginx.conf -v ./data/nginx/passwd_scrcpy_web:/etc/nginx/passwd_scrcpy_web -v ./data/nginx/conf.d:/etc/nginx/conf.d -p 8055:80 --name \${NGINX} --link \${SCRCPY} nginx:1.24

sleep 5
echo -e "\n 5.install APK"
for file in ` ls ./data/scrcpy-web/apk`
do
    if [[ -f "./data/scrcpy-web/apk/"\$file ]]; then
      echo "installing \$file"
      docker exec -it \${SCRCPY} adb install /apk/\$file
    fi
done
EOF

chmod +x ./start.sh
./start.sh

echo "Cleaning up"
silent apt-get -y autoremove
silent apt-get -y autoclean
echo "Cleaned"

##############
