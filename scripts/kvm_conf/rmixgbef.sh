echo 0 > /sys/bus/pci/devices/0000:18:00.0/sriov_numvfs
rmmod ixgbevf
echo 20 > /sys/bus/pci/devices/0000:18:00.0/sriov_numvfs
./setup-vf.sh
