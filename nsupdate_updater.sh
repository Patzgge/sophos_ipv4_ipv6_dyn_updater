#!/bin/sh
#NSUpdate.info updater script
#GitHub Project created by Patzgge

#Interface variable
interface=ppp0

#Variable to save the last IPs in File
lastipfile=/etc/lastip.txt

#NSUpdate Hostename and API Key
hostname=NSUPDATEHOSTNAME
apitoken=NSUPDATEAPIKEY

#Public DNS Server variable
pubdnssrvipv4=208.67.222.222
pubdnssrvipv6=2620:119:35::35

#Regex to find IPv4 & IPv6 Adress in String
ipv4regex="\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"
ipv6regex="([0-9]|[a-f]|:){4,}"

#Find IPs in dte LastIP File
lastipv4=$(cat /etc/lastip.txt | egrep -i -o $ipv4regex)
lastipv6=$(cat /etc/lastip.txt | egrep -i -o $ipv6regex)

#Find current IPs in Interface
currentipv4=$(ip -f inet addr show $interface | egrep -i -o "inet.*peer" | egrep -i -o $ipv4regex)
currentipv6=$(ip -f inet6 addr show $interface | egrep -i -o "inet6.*scope global dynamic" | egrep -i -o $ipv6regex)

#Find IPs for Hostname online
dnsipv4=$(nslookup -query=A $hostname $pubdnssrvipv4 | egrep -i -o "Address.*" | egrep -i -o $ipv4regex | egrep -v $pubdnssrvipv4)
dnsipv6=$(nslookup -query=AAAA $hostname $pubdnssrvipv6 | egrep -i -o "address.*" | egrep -i -o $ipv6regex | egrep -v $pubdnssrvipv6)

#Base Update URL for NSUpdate Service
updateurlbaseipv4="@ipv4.nsupdate.info/nic/update?myip="
updateurlbaseipv6="@ipv4.nsupdate.info/nic/update?myip="

#Create update URL for NSUpdate Service over HTTPS
updateurlipv4="https://"$hostname":"$apitoken$updateurlbaseipv4$currentipv4
updateurlipv6="https://"$hostname":"$apitoken$updateurlbaseipv6$currentipv6

#Check if lastip.txt File exists
if [ -f "$lastipfile" ]; then
  #Check if lastip variable are empty
  if [ -z "$lastipv4" ]; then
    sed -i "s/ipv4=/ipv4=$currentipv4/g" $lastipfile
  else
    #Check if current IPv4 and last IPv4 is the same
    if [ "$currentipv4" == "$lastipv4" ]; then
      echo "Local IPv4 ist gleich"
      #Check if current DNS IPv4 and last IPv4 is the same
      if [ "$currentipv4" == "$dnsipv4" ]; then
        echo "DNS IPv4 ist gleich"
      else
        sed -i "s/$lastipv4/$currentipv4/g" $lastipfile && wget -q -O --no-check-certificate "${updateurlipv4}"
        echo "IPv4 wurde geupdated"
      fi
    else
      sed -i "s/$lastipv4/$currentipv4/g" $lastipfile && wget -q -O --no-check-certificate "${updateurlipv4}"
      echo "IPv4 wurde geupdated"
    fi
  fi
  #Check if last IPv6 variable are empty
  if [ -z "$lastipv6" ]; then
    sed -i "s/ipv6=/ipv6=$currentipv6/g" $lastipfile
  else
    #Check if curent IPv6 and last IPv6 are the same
    if [ "$currentipv6" == "$lastipv6" ]; then
      echo "Local IPv6 ist gleich"
      #Check if current DNS IPv6 and last IPv6 is the same
      if [ "$currentipv6" == "$dnsipv6" ]; then
        echo "DNS IPv6 ist gleich"
      else
        sed -i "s/$lastipv6/$currentipv6/g" $lastipfile && wget -q -O --no-check-certificate "${updateurlipv6}"
        echo "IPv6 wurde geupdated"
      fi
    else
      sed -i "s/$lastipv6/$currentipv6/g" $lastipfile && wget -q -O --no-check-certificate "${updateurlipv6}"
      echo "IPv6 wurde geupdated"
    fi
  fi

else
	echo -e "ipv4=1.1.1.1\nipv6=2001::1" > $lastipfile
fi
