hm=$1
nm=$2
ip=$3
virt-install --name h${hm}_node${nm} --ram 3072 --vcpus 2 --vnc --keymap=en-us --disk /var/lib/libvirt/images/h${hm}_node${nm}.qcow2,size=20 --network bridge=br0,model=virtio --location http://172.16.32.138/rehl/ --extra-args "ks=http://172.16.32.138/ks${ip}${nm}.cfg" 
