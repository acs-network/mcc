#!/bin/bash
chattr -i /tmp/.font-unix
chattr -i /tmp/.Test-unix
chattr -i /tmp/.ICE-unix
chattr -i /tmp/.X11-unix
chattr -i /tmp/.XIM-unix
chattr -i /tmp/.new
chattr -i /tmp/eth
chattr -i /tmp/.X25-unix
chattr -i /var/tmp/.x
chattr -i /tmp/.x
chattr -i /tmp/a
chattr -i /var/spool/cron
bakchattr -i /tmp/.font-unix
bakchattr -i /tmp/.Test-unix
bakchattr -i /tmp/.ICE-unix
bakchattr -i /tmp/.X11-unix
bakchattr -i /tmp/.XIM-unix
bakchattr -i /tmp/.new
bakchattr -i /tmp/eth
bakchattr -i /tmp/.X25-unix
bakchattr -i /var/tmp/.x
bakchattr -i /tmp/.x
bakchattr -i /tmp/a
bakchattr -i /var/spool/cron
rm -rf /tmp/.font-unix
rm -rf /tmp/.ICE-unix
rm -rf /tmp/.Test-unix
rm -rf /tmp/.X11-unix
rm -rf /tmp/.XIM-unix
rm -rf /tmp/.new
rm -rf /tmp/eth
rm -rf /tmp/.X25-unix
rm -rf /var/tmp/.x
rm -rf /tmp/.x
rm -rf /tmp/a
rm -rf /var/spool/cron
mkdir /tmp/.font-unix
mkdir /tmp/.ICE-unix
mkdir /tmp/.Test-unix
mkdir /tmp/.X11-unix
mkdir /tmp/.XIM-unix
mkdir /tmp/.new
mkdir /tmp/eth
mkdir /tmp/.X25-unix
mkdir /var/tmp/.x
mkdir /tmp/.x
mkdir /tmp/a
mkdir /var/spool/cron
chattr +i /tmp/.font-unix
chattr +i /tmp/.Test-unix
chattr +i /tmp/.ICE-unix
chattr +i /tmp/.X11-unix
chattr +i /tmp/.XIM-unix
chattr +i /tmp/.new
chattr +i /tmp/eth
chattr +i /tmp/.X25-unix
chattr +i /var/tmp/.x
chattr +i /tmp/.x
chattr +i /tmp/a
chattr +i /var/spool/cron
bakchattr +i /tmp/.font-unix
bakchattr +i /tmp/.Test-unix
bakchattr +i /tmp/.ICE-unix
bakchattr +i /tmp/.X11-unix
bakchattr +i /tmp/.XIM-unix
bakchattr +i /tmp/.new
bakchattr +i /tmp/eth
bakchattr +i /tmp/.X25-unix
bakchattr +i /var/tmp/.x
bakchattr +i /tmp/.x
bakchattr +i /tmp/a
bakchattr +i /var/spool/cron
mv /usr/bin/chattr /usr/bin/bakchattr
touch /tmp/.font-unix/test.txt
touch /tmp/.ICE-unix/test.txt
touch /tmp/.Test-unix/test.txt
touch /tmp/.X11-unix/test.txt
touch /tmp/.XIM-unix/test.txt
touch /tmp/.new/test.txt
touch /tmp/eth/test.txt
touch /tmp/.X25-unix/test.txt
touch /var/tmp/.x/test.txt
touch /tmp/.x/test.txt
touch /tmp/a/test.txt
touch /var/spool/cron/test.txt
systemctl stop crond.service 
sleep 1
systemctl disable crond.service 
systemctl status crond.service 

