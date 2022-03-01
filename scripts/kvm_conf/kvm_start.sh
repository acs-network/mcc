#! /bin/bash
h_id=$1
ip_end=$2

for ((i=0; i<$ip_end; i++)); do
   virsh start h${h_id}_node${i}
done
