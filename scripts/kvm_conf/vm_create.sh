#!/bin/bash
cmd=$1
hm=$2
nm=$3
ip=$4

set_vm()
{
  for ((i=0; i<$nm; i++)); do
  	bash -s $hm $i $ip< install-vitr.sh &
  	#bash -s $i $ip < ksset_kvm.sh &
  done
}

set_vf()
{

  for ((i=0; i<$nm; i++)); do
  	bash -s $hm $i < addvf.sh 
  	virsh define /etc/libvirt/qemu/h${hm}_node${i}.xml
  done
  
  for ((i=0; i<$nm; i++)); do
        sleep 5
        virsh start h${hm}_node${nm}
  done
}

if [ "$cmd" == "help" ]; then
        echo "./vm_create.sh <command> <number of nodes>"
        echo "vm: install vm"
        echo "vf: bond vf to vm"
elif [ "$cmd" == "vm" ]; then
  set_vm
elif [ "$cmd" == "vf" ]; then
  set_vf
else
  echo "Warning, Unknown option."
fi

