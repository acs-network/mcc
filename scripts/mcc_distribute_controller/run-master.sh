#!/bin/bash

systemctl stop firewalld

ntpdate 172.16.32.140

if [ "$2" = "" ]; then
  SETUP=60
else
  SETUP=$2
fi

if [ "$3" = "" ]; then
  NUM=5
else
  NUM=$3
fi

TOTAL_CONC=$1
CONC=$( expr $TOTAL_CONC \* 10000 / $NUM )
BURST=$( expr $CONC / 60 )
#BURST=$( expr $CONC / 120 )

#./master --device eno1 -e 1 -s 1 -w 1 -c 12 -b 12 -n 2 -i 140 -t 100000 -d 1000 -r 1.0
echo "./master --device eno1 -e 60 -s $SETUP -w 5 -c $CONC -b $BURST -n $NUM -i 140 -t 100000 -d 60000 -r 0.05"
sleep 5
./master --device eno1 -e 60 -s $SETUP -w 20 -g 0 -c $CONC -b $BURST -n $NUM -i 140 -t 100000 -d 60000 -r 0.05
