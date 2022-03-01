com=$1
nic=$2
if [ "$nic" == "w" ]; then
    PCI_PATH="0000:18:00.1"
    dev=enp24s0f1
else
    PCI_PATH="0000:18:00.0"
    echo " $PCI_PATH "
    dev=enp24s0f0
fi

echo ""
if [ "$com" == "ub" ]; then
	RTE_SDK=$PWD/dpdk
	${RTE_SDK}/usertools/dpdk-devbind.py --status
	echo -n "Enter name of kernel driver to bind the device to: "
	read DRV
    echo " ${RTE_SDK}/usertools/dpdk-devbind.py -b $DRV $PCI_PATH "
	${RTE_SDK}/usertools/dpdk-devbind.py -b $DRV $PCI_PATH && echo "OK"
	ifconfig dpdk0 down
    if [ "nic" == "w" ]; then
	    ifconfig $dev 192.168.140.100/16 up
    else
        ifconfig $dev 192.168.140.100/16 up
    fi
elif [ "$com" == "b" ]; then
	ifconfig $dev down
	RTE_SDK=$PWD/dpdk
	${RTE_SDK}/usertools/dpdk-devbind.py --status
    ${RTE_SDK}/usertools/dpdk-devbind.py -b igb_uio $PCI_PATH && echo "OK"
    if [ "nic" == "w" ]; then
	    ifconfig dpdk0 192.168.140.100/16 up
    else
        ifconfig dpdk0 192.168.140.100/16 up
    fi
fi

