nodes=$1
cmd=$2
filename="$3"
com=$4

set_lnk()
{
	id=0
    for line in `cat $filename`
    do
		ssh root@$line 'ifconfig enp134s0f0 down && mkdir -p /home/songhui/qingyun/dpdk-lnk && cd /home/songhui/qingyun/dpdk-lnk && ln -s ../dpdk/x86_64-native-linuxapp-gcc/include incude && ln -s ../dpdk/x86_64-native-linuxapp-gcc/lib lib' &
        id=$(($id+1))
    	if [ $id -eq $nodes ]
    	then
        	break;
    	fi
	done
}

set_qingyun()
{
	id=0
    for line in `cat $filename`
    do
		echo "Node $id, setting ip"
    	tmp=${line%.*}
    	ip1=${tmp##*.}
    	ip2=${line##*.}
		ssh root@$line 'cd /home/songhui/qingyun/ && ./setup_mtcp_dpdk_env.sh < dpdk-inputfile && ifconfig dpdk0 192.168.'$ip2'.100/16 up' &
        id=$(($id+1))
    	if [ $id -eq $nodes ]
    	then
        	break;
    	fi
	done
}

setdir_redis()
{
	num=$nodes
    id=0

    for line in `cat $filename`
    do
		echo "Node $id, setting redis"
		ssh root@$line 'bash -s' $num < dir-redis.sh &
        id=$(($id+1))
    	if [ $id -eq $nodes ]
    	then
        	break;
    	fi
    done
}

start_redis()
{
	num=$nodes
    id=0

    for line in `cat $filename`
    do
		echo "Node $id, $com redis"
		ssh root@$line 'bash -s' $num $com < setup-redis.sh &
        id=$(($id+1))
    	if [ $id -eq $nodes ]
    	then
        	break;
    	fi
    done
}

start_cleanvir()
{
	num=$nodes
    id=0

    for line in `cat $filename`
    do
		echo "Node $id, $com redis"
		ssh root@$line 'bash -s' < clear-all-202106.sh &
		ssh root@$line 'reboot' &
        id=$(($id+1))
    	if [ $id -eq $nodes ]
    	then
        	break;
    	fi
    done
}

mod_pw()
{
	read -p "Please enter a new password :" pass
	######ip.txt 为目标主机ip
	for ip in `cat $filename`
	do
	{
		ping -c1 -W1 $ip &>/dev/null
     	if [ $? -eq 0 ];then
     		 ssh $ip "echo $pass |passwd --stdin root"
             if [ $? -eq 0 ];then
                echo "$ip" >> success_`date +%F`.txt
                echo "$pass" >> success_`date +%F`.txt
                           else
                echo "$ip" >> fail_`date +%F`.txt
             fi
    	else
       		 echo "$ip" >>fail_`date +%F`.txt 
    	fi
	}&
	done
	wait
	echo "all ok ."
}

setup_nopw()
{
	read -p "start ip:" beginip
    read -p "end ip:" endip
	read -p "passwd: " mima
	begarray=(${beginip//./ })
	endarray=(${endip//./ })
	if [ "${begarray[0]}" = "${endarray[0]}" -a "${begarray[1]}" = "${endarray[1]}" -a "${begarray[
2]}" = "${endarray[2]}" ]; then                
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

set_sysconf()
{
	num=$nodes
    id=0

    for line in `cat $filename`
    do
		echo "Node $id, $com redis"
		ssh root@$line 'bash -s' < rediscf.sh &
        id=$(($id+1))
    	if [ $id -eq $nodes ]
    	then
        	break;
    	fi
    done
}

scp()
{	
	./scp_file.sh /home/songhui/qingyun /home/songhui/ $filename
	./scp_file.sh redis.conf /home/songhui/qingyun/redis-4.0.2/src/ $filename
}

if [ "$cmd" == "help" ]; then
    echo "./deploy.sh <command> <number of nodes> <hosts file>"
    echo "command:"
    echo "lnk       : set dpdk soft link"
    echo "qyun   	: deploy qingyun" 
    echo "redir     : set redis path and configuration"
    echo "redis   	: start/kill redis process" 
    echo "scp   	: scp redis files to multi hosts" 
elif [ "$cmd" == "lnk" ]; then
  set_lnk
elif [ "$cmd" == "qyun" ]; then
  set_qingyun
elif [ "$cmd" == "redir" ]; then
  setdir_redis
elif [ "$cmd" == "syscf" ]; then
  set_sysconf
elif [ "$cmd" == "redis" ]; then
  start_redis
elif [ "$cmd" == "scp" ]; then
  scp
elif [ "$cmd" == "np" ];then
  setup_nopw
elif [ "$cmd" == "vir" ];then
  start_cleanvir
elif [ "$cmd" == "mp" ];then
  mod_pw
else
  echo "Warning, Unknown option."
fi
