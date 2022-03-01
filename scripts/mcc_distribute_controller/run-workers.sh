#!/bin/bash

nodes=$1
cmd=$2
filename="$3"

start_test() 
{
	id=0
	for line in `cat $filename`
	do 
		echo "Start node $id to server"
		ssh root@$line 'bash -s' $line $id 192.168.60.100 < load_test.sh &
		id=$(($id+1))
		if [ $id -eq $nodes ] 
		then
				break;  
		fi
	done
}


stop_test()
{
	id=0
  echo "Killing all loaders..."
	for line in `cat $filename`
  do
    ssh root@$line 'pkill -9 worker; scp /home/mcctest/client_'$id'_log root@172.16.32.140:/home/songhui/mcc/log/' &
		echo "Loader $id finished"
		id=$(($id+1))
		if [ $id -eq $nodes ] 
		then
				break;  
		fi
  done
}

if [ "$cmd" == "stop" ]; then
  stop_test
elif [ "$cmd" == "start" ]; then
  ./mcc-setup.sh $nodes sync $filename
  sleep 15
  start_test
  while true;do
    echo "input \"stop\" to stop the workers"
    read arg
    if [ "$arg" == "stop" ]; then
      break
    fi
  done
  stop_test
else
  echo "Warning, Unknown option."
fi


