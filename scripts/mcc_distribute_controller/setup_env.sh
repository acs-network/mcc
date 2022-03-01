#!/bin/bash

yum install -y gmp-devel
yum install -y numactl-devel
yum install -y boost-devel
#yum install -y bc
yum install -y pciutils
yum install -y wget
yum install -y vim
yum install -y gcc
yum install -y glibc-
yum install -y gcc-c++
yum install -y git
yum install -y ntp
yum install -y kernel-devel-$(uname -r)

cd /home/mcctest/downloads

tar -zxvf protobuf-cpp-3.5.0.tar.gz && cd protobuf-3.5.0/

./configure && make && make install

echo /usr/local/lib >> /etc/ld.so.conf && ldconfig

modprobe ip_conntrack

echo /usr/local/lib >> /etc/ld.so.conf
ldconfig

echo 10000000 > /proc/sys/fs/nr_open
echo 1 > /proc/sys/net/ipv4/tcp_tw_recycle
echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse
echo 5 > /proc/sys/net/ipv4/tcp_fin_timeout
echo 10000000 > /proc/sys/net/nf_conntrack_max

timedatectl set-ntp true
