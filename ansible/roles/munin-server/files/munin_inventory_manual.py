#!/usr/bin/python3
# script to generate munin inventory
# for numerated cluster nodes

# usage: script.py <begin> <end> [number of leading digits=0] <prefix> <postfix>
#
# for a single entry: script.py  "address"

# Example:
#
# script.py "0 2 server .domain,0 2 client .domain,website.domain"
#
# will output
#
# [server0.domain]
# address server0.domain
# [server1.domain]
# address server1.domain
# [client0.domain]
# address client0.domain
# [client1.domain]
# address client2.domain
# [webside.domain]
# address website.domain


import os
import sys

raw_lists = sys.argv[1].split(",")
inventory = ""

for hostlist in raw_lists:
    hostargs = hostlist.split(" ")
    try:
        if len(hostargs) == 1 :
            inventory = inventory + "[{0}]\naddress {0}\n".format(hostargs[0])

        elif len(hostargs) == 4 :
            for i in range(int(hostargs[0]), int(hostargs[1])):
                inventory = inventory + ("[{0}" + str(i) + "{1}]\naddress {0}" + str(i) + "{1}\n").format(hostargs[2], hostargs[3])
    except IndexError:
        print("something went wrong")

print(inventory)
