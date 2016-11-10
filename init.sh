#!/bin/bash




#start munin-node
/usr/sbin/munin-node

if [ "$INVENTORY_GEN" = "repo" ]
then

    # configure inventoy generation cronjob
    sed -i "s/sourceurl=/sourceurl=$HOSTS_REPO/g" /etc/cron.hourly/munin_inventory.sh
    /etc/cron.hourly/munin_inventory.sh

elif [ "$INVENTORY_GEN" = "list" ]
then
    # remove inventoy generation cronjob
    rm -f /etc/cron.hourly/munin_inventory.sh

    # generate inventrory by a given list
    touch /etc/munin/munin-conf.d/inventory
    /etc/munin/munin_inventory_manual.py "$HOSTS_LIST" >> /etc/munin/munin-conf.d/inventory
fi


# configure apaches vhost
sed -i "s/all granted/$APACHE_REQUIRE/g" /etc/apache2/vhosts.d/munin.conf
sed -i 's/ServerAdmin.*$/ServerAdmin '"$APACHE_MAIL"'/g' /etc/apache2/vhosts.d/munin.conf
sed -i 's/ServerName.*$/ServerName '"$APACHE_DOMAIN"'/g' /etc/apache2/vhosts.d/munin.conf

echo -e "account default\nfrom $NOTIFICATION_FROM\nhost $NOTIFICATION_RELAY" > /var/lib/munin/.msmtprc
echo -e "contact.$NOTIFICATION_NAME.command mail -s 'Munin notification' $NOTIFICATION_TO" > /etc/munin/munin-config.d/notification

#run munin-cron for the first time
su - munin --shell=/bin/bash -c "munin-cron --host localhost --debug"

#start cron
/usr/sbin/cron 

#start rrdcached
/usr/bin/rrdcached -B -b /var/lib/munin/ -p /run/munin/munin-rrdcached.pid -F -j /munintmp/rrdcached-journal/ -m 0660 -l unix:/run/munin/rrdcached.sock -w 1800 -z 1800 -f 3600
#fix rrdached permissions
/usr/bin/setfacl -m u:munin:rw /run/munin/rrdcached.sock

#start cgi-html
/usr/bin/spawn-fcgi -s /var/run/munin/munin-cgi-html.sock -P /var/run/munin/munin-cgi-html.pid -u wwwrun -g munin -M 0770 -U wwwrun -G www /srv/www/cgi-bin/munin-cgi-html 
   
#start cgi-graph 
/usr/bin/spawn-fcgi -s /var/run/munin/munin-cgi-graph.sock -P /var/run/munin/munin-cgi-graph.pid -u wwwrun -g munin -M 0770 -U wwwrun -G www /srv/www/cgi-bin/munin-cgi-graph 

#fix permissions
chown -R munin:munin /var/run/munin

exec $@
