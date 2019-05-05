#!/bin/sh
#NSUpdate.info updater script

interface=ppp0
ipv4regex="\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"
ipv6regex="([0-9]|[a-f]|:){4,}"

updateurlbaseipv4="https://DYNHOSTNAME.nsupdate.info:NSUPDATESECRET@ipv4.nsupdate.info/nic/update?myip="
updateurlbaseipv6="https://DYNHOSTNAME.nsupdate.info:NSUPDATESECRET@ipv4.nsupdate.info/nic/update?myip="

currentipv4=$(ip -f inet addr show $interface | egrep -i -o "inet.*peer" | egrep -i -o $ipv4regex)
currentipv6=$(ip -f inet6 addr show $interface | egrep -i -o "inet6.*scope global dynamic" | egrep -i -o $ipv6regex)

updateurlipv4=$updateurlbaseipv4$currentipv4
updateurlipv6=$updateurlbaseipv6$currentipv6

wget -q -O --no-check-certificate "${updateurlipv4}"
wget -q -O --no-check-certificate "${updateurlipv6}"
