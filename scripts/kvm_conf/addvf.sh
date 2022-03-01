hm=$1
i=$2

m=$(($i / 4))
index=$(($i % 4))
fu=$(($index * 2))

sed -i "69a <hostdev mode='subsystem' type='pci' managed='yes'>\\
<source>\\
<address domain='0x0000' bus='0x18' slot='0x1${m}' function='0x${fu}'/>\\
</source>\\
</hostdev>" /etc/libvirt/qemu/h${hm}_node${i}.xml 



