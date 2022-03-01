#!/bin/bash
brctl addbr br0
ifconfig br0 up

brctl addif br0 eno1 && brctl stp br0 on && ifconfig eno1 0.0.0.0 && ifconfig br0 172.16.32.140 netmask 255.255.0.0 && route add default gw 172.16.0.254

