# !/bin/bash

ip_end=20
node=0

n=$(($node+170))

nm=$(echo "ibase=10;obase=16;$n"|bc)

#rmmod ixgbe

#modprobe ixgbe max_vfs=$1

for ((i=0; i<$ip_end; i++)); do
  offset=$(($i+97))
  hex=$(echo "ibase=10;obase=16;$offset"|bc)
  #echo $hex
  ip link set dev enp24s0f0 vf $i mac 08:61:1f:$nm:$hex:18
  ip link set dev enp24s0f0 vf $i trust on
done 
