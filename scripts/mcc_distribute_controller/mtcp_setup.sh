#!/bin/bash
      
ip1=$1 
ip2=$2

#yum install -y git

#mkdir /home/songhui

#cd /home/songhui

#git clone http://172.16.32.104/beide123/infgen.git

#cd infgen

#git submodule init
#git submodule update

#yum install -y kernel-devel-$(uname -r)
yum install -y automake

#cd /home/songhui/infgen/mtcp

#cp /home/dpdk-inputfile .

#git submodule init
#git submodule update
 
#export RTE_SDK=`echo $PWD`/dpdk
#export RTE_TARGET=x86_64-native-linuxapp-gcc
      
#ifconfig ens9 down
#./setup_mtcp_dpdk_env.sh < dpdk-inputfile

systemctl reload mtcp-auto

systemctl start mtcp-auto

systemctl enable mtcp-auto
     
ifconfig dpdk0 192.168.$ip1.$ip2 netmask 255.255.0.0 up

#autoreconf -ivf
#./configure --with-dpdk-lib=$RTE_SDK/$RTE_TARGET
#make


