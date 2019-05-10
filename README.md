1. enable SSH on Sophos
2. log in to Sophos using the user loginuser
3. change to the root user with "sudo su".
4. Create bash script either with "vim /etc/nsupdate_updater.sh" or "vim /etc/freedns_updater.sh"
5. Change file permission with "chmod 777 /etc/nsupdate_updater.sh" or "chmod 777 /etc/freedns_updater.sh"
6. enter "crontab -e" into the console
7. add the following line
          "# NSUpdate Updater
          */5 * * * * /etc/nsupdate_updater.sh"
    or
          "# FreeDNS Updater 
          */15 * * * * /etc/freedns_updater.sh"
8. press ESC and leave crontab with ":q" again

Now the Bash Script is called every 5/15 minutes via a cronjob
