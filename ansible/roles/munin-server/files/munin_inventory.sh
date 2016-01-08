#!/bin/bash
targetdir=/root/hosts_checkout
sourceurl=

if [ -d $targetdir/.git ]
then
    cd $targetdir
    git remote set-url origin $sourceurl
    git pull -q
else
    mkdir -p $targetdir
    git clone -q $sourceurl $targetdir
    cd $targetdir
fi

./buildfiles --munin
cp build/muninhosts /etc/munin/munin-conf.d/
echo -e "[localhost]\naddress localhost\nuse_node_name yes" >> /etc/munin/munin-conf.d/muninhosts 
