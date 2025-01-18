###############

echo "Installing Dependencies"

silent() { "$@" >/dev/null 2>&1; }

silent apt-get install -y curl sudo mc
echo "Installed Dependencies"

echo deb http://deb.debian.org/debian bullseye-backports main >> /etc/apt/sources.list
silent apt-get update -y
silent apt-get install -t bullseye-backports qemu-system python3 -y

if [ ! -e /dev/kvm ]; then
   mknod /dev/kvm c 10 232
   chmod 777 /dev/kvm
   chown root:kvm /dev/kvm
fi

cd /root

wget https://raw.githubusercontent.com/minlearn/appp/master/_build/osxkvm/boot.img.gz -O boot.img.gz
gunzip boot.img.gz

wget https://raw.githubusercontent.com/kholia/OSX-KVM/master/OVMF_CODE.fd -O OVMF_CODE.fd
wget https://raw.githubusercontent.com/kholia/OSX-KVM/master/OVMF_VARS.fd -O OVMF_VARS.fd
wget https://raw.githubusercontent.com/kholia/OSX-KVM/master/fetch-macOS-v2.py -O fetch.py
python3 fetch.py --action download --board-id Mac-2BD1B31983FE1663
echo "creating osxhd ..."
qemu-img create -f qcow2 BigSur-HD.qcow2 50G
echo "creating osxhd done"

#done on the host already
#echo 1 > /sys/module/kvm/parameters/ignore_msrs


if [ $(lscpu | grep "Vendor ID" | awk '{print $3}') == "GenuineIntel" ]; then
  cpuoptions="host,kvm=on,l3-cache=on,+hypervisor,migratable=no,vendor=GenuineIntel,vmware-cpuid-freq=on,-pdpe1gb"
fi
if [ $(lscpu | grep "Vendor ID" | awk '{print $3}') == "AuthenticAMD" ]; then
  cpuoptions="Haswell-noTSX,vendor=GenuineIntel,+invtsc,+hypervisor,kvm=on,vmware-cpuid-freq=on"
fi

tee -a start.sh > /dev/null <<EOF

if [ ! -e /dev/kvm ]; then
   mknod /dev/kvm c 10 232
   chmod 777 /dev/kvm
   chown root:kvm /dev/kvm
fi

args=(
 -nodefaults
 -cpu ${cpuoptions}
 -smp 2,sockets=1,dies=1,cores=2,threads=1
 -m 4G
 -machine type=q35,smm=off,graphics=off,vmport=off,dump-guest-core=off,hpet=off,accel=kvm
 -enable-kvm
 -global kvm-pit.lost_tick_policy=discard
 -uuid 76E01D9D-C0DD-4887-A6E9-D880107AD160
 -display vnc=:1
 -vga vmware
 -monitor telnet:localhost:7100,server,nowait,nodelay
 -name macos,process=macos,debug-threads=on
 -device nec-usb-xhci,id=xhci
 -device usb-kbd,bus=xhci.0
 -global nec-usb-xhci.msi=off
 -device usb-tablet
 -netdev user,id=hostnet0,host=20.20.20.1,net=20.20.20.0/24,dhcpstart=20.20.20.21,hostname=QEMU,hostfwd=tcp::22-20.20.20.21:22,hostfwd=tcp::3389-20.20.20.21:3389,hostfwd=tcp::5900-20.20.20.21:5900
 -device virtio-net-pci,romfile=,netdev=hostnet0,mac=00:16:CB:BD:8C:9E,id=net0
 -device virtio-blk-pci,drive=InstallMedia,bus=pcie.0,addr=0x6
 -drive file=./com.apple.recovery.boot/BaseSystem.dmg,id=InstallMedia,format=dmg,cache=unsafe,readonly=on,if=none
 -drive file=./BigSur-HD.qcow2,id=data3,format=qcow2,cache=none,aio=native,discard=on,detect-zeroes=on,if=none
 -device virtio-blk-pci,drive=data3,bus=pcie.0,addr=0xa,iothread=io2,bootindex=3
 -object iothread,id=io2
 -device virtio-blk-pci,drive=OpenCore,bus=pcie.0,addr=0x5,bootindex=9
 -drive file=./boot.img,id=OpenCore,format=raw,cache=unsafe,readonly=on,if=none
 -smbios type=2
 -rtc base=utc,base=localtime
 -global ICH9-LPC.disable_s3=1
 -global ICH9-LPC.disable_s4=1
 -global ICH9-LPC.acpi-pci-hotplug-with-bridge-support=off
 -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
 -drive if=pflash,format=raw,readonly=on,file=./OVMF_CODE.fd
 -drive if=pflash,format=raw,file=./OVMF_VARS.fd
 -object rng-random,id=objrng0,filename=/dev/urandom
 -device virtio-rng-pci,rng=objrng0,id=rng0,bus=pcie.0,addr=0x1c
 -device virtio-balloon-pci,id=balloon0,bus=pcie.0,addr=0x4
)

qemu-system-x86_64 "\${args[@]}"
EOF
chmod +x ./start.sh


echo "Cleaning up"
silent apt-get -y autoremove
silent apt-get -y autoclean
echo "Cleaned"

./start.sh

##############
