PA=/home/songhui/infgen
cp -r $PA .
cp dpdk-setup.sh infgen/mtcp/dpdk/usertools/
cp -r $PA/downloads/protobuf-cpp-3.5.0.tar.gz .
cp $PA/build/release/apps/distributed_mcc/master .
cp $PA/build/release/apps/distributed_mcc/worker .
cp -r $PA/build/release/apps/distributed_mcc/config .
cp $PA/build/release/apps/distributed_mcc/worker .
cp -r $PA/mtcp/dpdk/x86_64-native-linuxapp-gcc/kmod .
cp -r $PA/mtcp/dpdk-iface-kmod/dpdk_iface_main .
cp $PA/mtcp/dpdk-iface-kmod/dpdk_iface.ko .

