#!/bin/sh
#NSUpdate.info updater script
#GitHub Project created by Patzgge

echo "---------------------------------------"
current_date=$(date "+%d.%m.%Y")
echo "Current Date : $current_date"
current_time=$(date "+%H:%M:%S")
echo "Current Time : $current_time"

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

#Backup Public DNS Server variable
backuppubdnssrvipv4=8.8.8.8
backuppubdnssrvipv6=2001:4860:4860::8888

#Regex to find IPv4 & IPv6 Adress in String
ipv4regex="\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"
ipv6regex="([0-9]|[a-f]|:){4,}"

#Find IPs in dte LastIP File
lastipv4=$(cat $lastipfile | egrep -i -o $ipv4regex)
lastipv6=$(cat $lastipfile | egrep -i -o $ipv6regex)

#Find current IPs in Interface
currentipv4=$(ip -f inet addr show $interface | egrep -i -o "inet.*peer" | egrep -i -o $ipv4regex)
currentipv6=$(ip -f inet6 addr show $interface | egrep -i -o "inet6.*scope global dynamic" | egrep -i -o $ipv6regex)

#Find IPs on Plublic DNS Servers
dnsipv4=$(nslookup -query=A $hostname $pubdnssrvipv4 | egrep -i -o "Address.*" | egrep -i -o $ipv4regex | egrep -v $pubdnssrvipv4)
dnsipv6=$(nslookup -query=AAAA $hostname $pubdnssrvipv6 | egrep -i -o "address.*" | egrep -i -o $ipv6regex | egrep -v $pubdnssrvipv6)

#Find IPs on Backup Public DNS Servers
backupdnsipv4=$(nslookup -query=A $hostname $backuppubdnssrvipv4 | egrep -i -o "Address.*" | egrep -i -o $ipv4regex | egrep -v $backuppubdnssrvipv4)
backupdnsipv6=$(nslookup -query=AAAA $hostname $backuppubdnssrvipv6 | egrep -i -o "address.*" | egrep -i -o $ipv6regex | egrep -v $backuppubdnssrvipv6)

#Base Update URL for NSUpdate Service
updateurlbaseipv4="@ipv4.nsupdate.info/nic/update?myip="
updateurlbaseipv6="@ipv4.nsupdate.info/nic/update?myip="

#Create update URL for NSUpdate Service over HTTPS
updateurlipv4="https://"$hostname":"$apitoken$updateurlbaseipv4$currentipv4
updateurlipv6="https://"$hostname":"$apitoken$updateurlbaseipv6$currentipv6

#Function to run an DNS Update for IPv4
function update_ipv4 {
               sed -i "s/$lastipv4/$currentipv4/g" $lastipfile;
               wget -q -O --no-check-certificate "${updateurlipv4}";
		           echo "IPv4 has been updated";
}

#Function to run an DNS Update for IPv6
function update_ipv6 {
                      sed -i "s/$lastipv6/$currentipv6/g" $lastipfile;
                      wget -q -O --no-check-certificate "${updateurlipv6}";
                      echo "IPv6 has been updated";
}

#Function display IPv4 is equal in local file
function ipv4_equal_local {
                      echo "IPv4 in lastip.txt file is equal";
}

#Function display IPv6 is equal in local file
function ipv6_equal_local {
                    echo "IPv6 in lastip.txt file is equal";
}

#Function display IPv4 is equal on Public DNS Server
function ipv4_equal_dns {
                      echo "IPv4 over Public DNS is equal";
}

#Function display IPv6 is equal on Public DNS Server
function ipv6_equal_dns {
                    echo "IPv6 over Public DNS is equal";
}

#Function display IPv4 is equal on Public DNS Server and Backup Public DNS Server
function ipv4_equal_both_dns {
                      echo "IPv4 is equal Public DNS and Backup Public DNS";
}

#Function display IPv6 is equal on Public DNS Server and Backup Public DNS Server
function ipv6_equal_both_dns {
                    echo "IPv6 is equal Public DNS and Backup Public DNS";
}

#Function display IPv4 is not equal on Public DNS Server and Backup Public DNS Server
function ipv4_dns_missmatch {
                    echo "IPv4 missmatch on Public DNS Server";
}

#Function display IPv6 is not equal on Public DNS Server and Backup Public DNS Server
function ipv6_dns_missmatch {
                    echo "IPv6 missmatch on Public DNS Server";
}

if [ -f "$lastipfile" ]; then
  if [ -z $currentipv4 ]; then
    echo "IPv4 no Interface IP existing"
  else
    echo "IPv4 Interface IP existing"
    if [ -z "$lastipv4" ]; then
      sed -i "s/ipv4=/ipv4=$currentipv4/g" $lastipfile
    else
      if [ "$currentipv4" == "$lastipv4" ]; then
        ipv4_equal_local
        if [ "$dnsipv4" == "$backupdnsipv4" ]; then
          ipv4_equal_both_dns
          if [ "$currentipv4" == "$dnsipv4" ]; then
            ipv4_equal_dns
          else
            update_ipv4
          fi
        else
          ipv4_dns_missmatch
        fi
      else
        update_ipv4
      fi
    fi
  fi

  if [ -z $currentipv6 ]; then
    echo "IPv6 no Interface IP existing"
  else
    echo "IPv6 Interface IP existing"
    if [ -z "$lastipv6" ]; then
      sed -i "s/ipv6=/ipv6=$currentipv6/g" $lastipfile
    else
      if [ "$currentipv6" == "$lastipv6" ]; then
        ipv6_equal_local
        if [ "$dnsipv6" == "$backupdnsipv6" ]; then
          ipv6_equal_both_dns
          if [ "$currentipv6" == "$dnsipv6" ]; then
            ipv6_equal_dns
          else
            update_ipv6
          fi
        else
          ipv6_dns_missmatch
        fi
      else
        update_ipv6
      fi
    fi
  fi

else
	echo -e "ipv4=1.1.1.1\nipv6=2001::1" > $lastipfile
fi
