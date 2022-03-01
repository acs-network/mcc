#!/bin/bash

nodes=$1
cmd=$2
filename="$3"

set_htop() 
{
	id=0
	for line in `cat $filename`
	do 
		echo "node $id setting environment variables"
		ssh root@$line 'yum install -y epel-release && yum install -y htop'&
		id=$(($id+1))
		if [ $id -eq $nodes ] 
		then
				break;  
		fi
	done
}

set_env() 
{
	id=0
	for line in `cat $filename`
	do 
		echo "node $id setting environment variables"
		ssh root@$line 'bash -s' < setup_env.sh &
		id=$(($id+1))
		if [ $id -eq $nodes ] 
		then
				break;  
		fi
	done
}

set_mtcp() 
{
	id=0
	for line in `cat $filename`
	do 
		echo "node $id deploying DPDK"
    		tmp=${line%.*}
    		ip1=${tmp##*.}
    		ip2=${line##*.}
		ssh root@$line 'bash -s' $ip1 $ip2 < mtcp_setup.sh &
		id=$(($id+1))
		if [ $id -eq $nodes ]
		then
				break;  
		fi
	done
}

set_ip() 
{
  id=0
  for line in `cat $filename`
  do
    echo "Node $id, setting ip"
    tmp=${line%.*}
    ip1=${tmp##*.}
    ip2=${line##*.}
    ssh root@$line 'ifconfig dpdk0 192.168.'$ip1'.'$ip2' netmask 255.255.0.0 up
'&    id=$(($id+1))
    if [ $id -eq $nodes ]
    then
        break;
    fi
  done
}

set_date() 
{
	id=0
	for line in `cat $filename`
	do 
		echo "node $id setting date"
		ssh root@$line 'mv /etc/localtime /etc/localtime.bak && ln -s /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime' &
		id=$(($id+1))
		if [ $id -eq $nodes ] 
		then
				break;  
		fi
	done
}

sync_ts()
{
	id=0
  echo "Synchronizing..."
	for line in `cat $filename`
  do
		#echo "node $id time synchronizing..."
    	#ssh root@$line 'systemctl disable firewalld && systemctl stop firewalld && yum install -y ntp && ntpdate 10.16.0.73' &
    	ssh root@$line 'ntpdate 10.16.0.73' &
		echo "Loader $id finished"
		id=$(($id+1))
		if [ $id -eq $nodes ] 
		then
				break;  
		fi
  done
}

set_cpu()
{
  id=0
  for line in `cat $filename`
  do
    tmp=${line%.*}
    ip1=${tmp##*.}
    ip2=${line##*.}
    hm=$(($ip2-140))
    for ((i=0; i<15; i++)); do
       cid=$(($i*2))
       ssh root@$line 'bash -s' $hm $i $cid < set_cpu.sh &
       echo "Loader h_${hm}_node${i} finished"
    done
    id=$(($id+1))
    if [ $id -eq $nodes ]
    then
         break;
    fi
  done

}


clean()
{
	id=0
  echo "Cleaning..."
	for line in `cat $filename`
  do
    ssh root@$line 'cd /home/mcctest/mcc && rm -f core.* log_* && cd /home/mcctest/httploader && rm -f core.* log_* && cd /home/mcctest/wanloader && rm -f core.* log_*' &
		echo "Loader $id finished"
		id=$(($id+1))
		if [ $id -eq $nodes ] 
		then
				break;  
		fi
  done
}

# For kernel stack
setup_vip()
{
  echo "Setting virtual ip..."
  id=0
  ip_start=50
  ip_end=150
  ip_block=3
  for line in `cat $filename`
  do  
		echo "node $id setting virtual IP address"
    ssh root@$line 'bash -s'  $ip_start $ip_end $ip_block up < ip_setup.sh &
    echo "Loader $id set."
    id=$(($id+1))
    if [ $id -eq $nodes ] 
    then
        break;  
    fi  
  done
}

setup_br()
{
    echo "Setting virtbr for kvm..."
    id=0
    for line in `cat $filename`
    do  
	echo "host $id setting virtual bridge"
        ssh root@$line 'bash -s'  $line < br0-setup.sh &
    	echo "Host $id set."
    	id=$(($id+1))
    	if [ $id -eq $nodes ] 
    	then
            break;  
        fi  
    done
    
}

setup_nopw()
{
	read -p "start ip:" beginip
	read -p "end ip:" endip
	read -p "passwd: " mima
	begarray=(${beginip//./ })
	endarray=(${endip//./ })
	if [ "${begarray[0]}" = "${endarray[0]}" -a "${begarray[1]}" = "${endarray[1]}" -a "${begarray[2]}" = "${endarray[2]}" ]; then
        	[ -f /root/.ssh/id_rsa ] || ssh-keygen -P "" -f /root/.ssh/id_rsa &> /dev/null
		rpm -q sshpass &> /dev/null || yum install sshpass -y &> /dev/null
		sed -i '/Checking ask/c StrictHostKeyChecking no' /etc/ssh/ssh_config
		begin=${begarray[3]}
		end=${endarray[3]}
		while [ "${begarray[3]}" -le "${endarray[3]}" ];do
			if ping -c1 -w1 ${endarray[0]}.${endarray[1]}.${endarray[2]}.${begarray[3]} &> /dev/null ; then
			{
				if sshpass -p $mima ssh-copy-id -i  /root/.ssh/id_rsa.pub ${endarray[0]}.${endarray[1]}.${endarray[2]}.${begarray[3]} &> /dev/null ;then
				echo ${endarray[0]}.${endarray[1]}.${endarray[2]}.${begarray[3]} success >> success.txt
				else
				echo ${endarray[0]}.${endarray[1]}.${endarray[2]}.${begarray[3]} error >> error.txt
				fi
				echo ${begarray[3]}
			}&
			else
				echo  ${endarray[0]}.${endarray[1]}.${endarray[2]}.${begarray[3]} host is unreachable >> error.txt
			fi
			let begarray[3]++
		done
		wait
	else
		echo Just support 1~254
	fi  
}

scp_all()
{
 id=0
 for line in `cat $filename`
    do  
	echo "host $id setting dir"
#        ssh root@$line 'bash -s' dirmk.sh &
        ssh root@$line 'mkdir -p /home/songhui'
        ssh root@$line 'mkdir -p /home/mcctest/downloads'
    	echo "Host $id set."
    	id=$(($id+1))
    	if [ $id -eq $nodes ] 
    	then
            break;  
        fi  
    done
 echo "Setting scp files..."
 ./scp_file.sh protobuf-cpp-3.5.0.tar.gz /home/mcctest/downloads $filename
 ./scp_file.sh worker /home/mcctest $filename
 ./scp_file.sh config /home/mcctest $filename
 ./scp_file.sh infgen /home/songhui/ $filename
}

set_dpdk()
{

 ./scp_file.sh kmod /home/songhui/infgen/mtcp/dpdk/x86_64-native-linuxapp-gcc/ $filename

 ./scp_file.sh dpdk_iface_main /home/songhui/infgen/mtcp/dpdk-iface-kmod/ $filename
 
 ./scp_file.sh dpdk_iface.ko /home/songhui/infgen/mtcp/dpdk-iface-kmod/ $filename
 ./scp_file.sh mtcp-auto.service /usr/lib/systemd/system/ $filename
}

clean_dir()
{
   id=0
   for line in `cat $filename`
      do
      echo "node $id clear dir"
      ssh root@$line 'rm /home/mcctest'
      ssh root@$line 'rm /home/mcctest/downloads'
      id=$(($id+1))
      if [ $id -eq $nodes ]
      then
        break;
      fi
   done

}

reboot_vm()
{
   id=0
   for line in `cat $filename`
      do
      echo "node $id reboot"
      ssh root@$line 'reboot'
      id=$(($id+1))
      if [ $id -eq $nodes ]
      then
        break;
      fi
   done

}

setup_vm()
{
   id=0
   for line in `cat $filename`
   do
      echo "node $id setting vm"
      ip=${line##*.}
      ssh root@$line 'bash -s' $cmd $id 12 $ip < vm_create.sh &
      id=$(($id+1))
      if [ $id -eq $nodes ]
      then
      	break;
      fi
   done

}

# For kernel stack
unset_vip()
{
  echo "Setting virtual ip..."
  id=0
  ip_start=50
  ip_end=150
  ip_block=3
  for line in `cat $filename`
  do  
		echo "node $id unsetting virtual IP address"
    ssh root@$line 'bash -s'  $ip_start $ip_end $ip_block down < ip_setup.sh &
    echo "Loader $id set."
    id=$(($id+1))
    if [ $id -eq $nodes ] 
    then
        break;
    fi
  done
}

## env 		: set kernel parameters
## mtcp		: deploy mTCP 
## ip 		: set ip of dpdk0
## sync		: NTP synchronization
## date		: modify region
## set_vip: set virtual IP address when using kernel stack
## unset_vip: unset virtual IP address when using kernel stack
## clean  : delete redundant files

if [ "$cmd" == "help" ]; then
	echo "./mcc_setup.sh <command> <number of nodes> <hosts file>"
	echo "command:"
  echo "env    		: set kernel parameters"
	echo "mtcp		: deploy mTCP" 
	echo "ip 		: set ip of dpdk0"
	echo "sync		: NTP synchronization"
	echo "date		: modify region"
	echo "set_vip		: set virtual IP address when using kernel stack"
	echo "unset_vip	: unset virtual IP address when using kernel stack"
	echo "clean  		: delete redundant files"
elif [ "$cmd" == "env" ]; then
  set_env
elif [ "$cmd" == "mtcp" ]; then
  set_mtcp
elif [ "$cmd" == "ip" ]; then
  set_ip
elif [ "$cmd" == "sync" ]; then
  sync_ts
elif [ "$cmd" == "br" ]; then
  setup_br
elif [ "$cmd" == "pass" ]; then
  setup_nopw
elif [ "$cmd" == "scp" ]; then
  scp_all
elif [ "$cmd" == "dpdk" ]; then
  set_dpdk
elif [ "$cmd" == "clr" ]; then
  clean_dir
elif [ "$cmd" == "reboot" ]; then
  reboot_vm
elif [ "$cmd" == "date" ]; then
  set_date
elif [ "$cmd" == "set_vip" ]; then
  setup_vip
elif [ "$cmd" == "unset_vip" ]; then
  unset_vip
elif [ "$cmd" == "clean" ]; then
  clean
elif [ "$cmd" == "htop" ]; then
  set_htop
else
  echo "Warning, Unknown option."
fi


