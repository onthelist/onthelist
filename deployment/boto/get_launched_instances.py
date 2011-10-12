#!/usr/bin/python

from connection import *

conn = get_conn()

with open('/home/www-server/init/launch_id', 'r') as l_file:
  launch_id = l_file.read().strip()

print launch_id
rsvns = conn.get_all_instances(filters={
  'tag-value': launch_id
})

rsvn = rsvns[0]
dns_names = [i.__dict__['dns_name'] for i in rsvn.instances]

# We could use the hostname.coffee script to get the local machine and
# eliminate it from the list, but as this is a failsafe anyway, we'll leave
# it in the list for the moment.

with open('/home/www-server/init/dns_names', 'w') as d_file:
  d_file.write("\n".join(dns_names))
