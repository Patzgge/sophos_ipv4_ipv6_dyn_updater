#!/bin/sh
#NSUpdate.info updater script

interface=ppp0
ipv4regex="\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"
ipv6regex="([0-9]|[a-f]|:){4,}"
lastipfile=/etc/lastip.txt

lastipv4=$(cat /etc/lastip.txt | egrep -i -o $ipv4regex)
lastipv6=$(cat /etc/lastip.txt | egrep -i -o $ipv6regex)

updateurlbaseipv4="https://NSUPDATEHOSTNAME.nsupdate.info:NSUPDATESECRET@ipv4.nsupdate.info/nic/update?myip="
updateurlbaseipv6="https://NSUPDATEHOSTNAME.nsupdate.info:NSUPDATESECRET@ipv6.nsupdate.info/nic/update?myip="

currentipv4=$(ip -f inet addr show $interface | egrep -i -o "inet.*peer" | egrep -i -o $ipv4regex)
currentipv6=$(ip -f inet6 addr show $interface | egrep -i -o "inet6.*scope global dynamic" | egrep -i -o $ipv6regex)

updateurlipv4=$updateurlbaseipv4$currentipv4
updateurlipv6=$updateurlbaseipv6$currentipv6

if [ -f "$lastipfile" ]; then

	if [ "$currentipv4" == "$lastipv4" ]; then
		echo "IPv4 ist gleich"
	else
		sed -i "s/$lastipv4/$currentipv4/g" /etc/lastip.txt
		wget -q -O --no-check-certificate "${updateurlipv4}"
	fi

	if [ "$currentipv6" == "$lastipv6" ]; then
		echo "IPv6 ist gleich"
	else
		sed -i "s/$lastipv6/$currentipv6/g" /etc/lastip.txt
		wget -q -O --no-check-certificate "${updateurlipv6}"
	fi

else
	echo -e "ipv4=1.1.1.1\nipv6=2001::1" > $lastipfile
fi
