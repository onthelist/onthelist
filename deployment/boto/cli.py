#!/usr/bin/python

from time import sleep
import os.path
import sys
import readline
import urllib2

from connection import *

INST_CNT = 4
LB_NAME = 'NoSSL-LB'
MIN_OK = 4
ZONES = ['b', 'd']

def status_tick():
  sys.stdout.write('.')
  sys.stdout.flush()

with open('./prod_image') as f:
  prod_image = f.read().strip()

print "Loading Image %s" % prod_image

image = get_conn().get_image(prod_image)

print "Starting %d Instances in Each Zone" % INST_CNT

instances = []
for zone in ZONES:
  rsvn = image.run(
    min_count=INST_CNT,
    max_count=INST_CNT,
    instance_type='t1.micro',
    placement='us-east-1%s' % zone,
    security_groups=['General'],
    key_name='speedykey.pem',
    user_data="""#!/bin/bash
        export NODE_PATH=/usr/local/lib/node_modules    
        
        cd /home/www-server/
        /usr/lib/git-core/git-clone git@github.com:onthelist/onthelist.git 2>&1 >> /var/log/speedy-deployment-git.log
        
        /usr/bin/chef-solo -j /home/www-server/onthelist/deployment/chef/node.json -c /home/www-server/onthelist/deployment/chef/solo.rb 2>&1 >> /var/log/speedy-deployment-chef.log
        
        mkdir /home/www-server/init
        touch /home/www-server/init/cloned
        chown -R www-server:www /home/www-server/
        chmod -R ug+rw /home/www-server
        """,
    monitoring_enabled=True)

  instances += rsvn.instances

ready_cnt = 0
while ready_cnt < len(instances):
  sleep(1)
  status_tick()

  for instance in instances:
    if instance.state == 'running':
      continue

    instance.update()
    if instance.state == 'running':
      ready_cnt += 1
      print "\n", instance, "Ready"

print ""
for instance in instances:
  print instance.id, instance.public_dns_name

new_ids = [r.id for r in instances]

def get_lb_status():
  return get_elb_conn().describe_instance_health(LB_NAME)

def print_lb_status():
  status = get_lb_status()

  for instance in status:
    code = ''
    if instance.reason_code != 'N/A':
      code = instance.reason_code

    print instance.instance_id, instance.state, code

def check_initted():
  for instance in instances:
    url = 'http://' + instance.public_dns_name + '/init/cloned'

    try:
      code = urllib2.urlopen(url, None, 3).getcode()
      if code != 200:
        raise IOError()

    except (IOError, urllib2.URLError):
      return False

  return True

added_to_lb = False
def add_to_lb():
  global added_to_lb

  print "Waiting for instances to pass health check..."
  while True:
    if check_initted():
      break
    
    status_tick()
    sleep(1)

  print "\nHealth Check Passed"

  ni = get_elb_conn().register_instances(LB_NAME, new_ids)

  added_to_lb = True

  print "%d Instances Now On LB (%d awaiting registration)" % (len(ni), len(instances))

old_insts = None
def remove_old_from_lb():
  global added_to_lb, old_insts

  if not added_to_lb:
    print "Can't remove old instances until new instances have been added."
    return

  status = get_lb_status()

  ok_cnt = 0
  for inst in status:
    if inst.instance_id in new_ids and inst.state == 'InService':
      ok_cnt += 1

  if ok_cnt < MIN_OK:
    print "Removing old instances would leave too few running instances (Have: %d, Need: %d)" % (ok_cnt, MIN_OK)
    return

  old_insts = []
  for inst in status:
    if inst.instance_id not in new_ids:
      old_insts.append(inst.instance_id)

  insts = get_elb_conn().deregister_instances(LB_NAME, old_insts)
  print "Removed old instances"

def revert_lb():
  global added_to_lb, old_insts
  
  if not added_to_lb:
    print "Never Added Instances, Nothing to Revert"
    return

  if old_insts:
    added = get_elb_conn().register_instances(LB_NAME, old_insts)
    print "Waiting for old servers to be registered..."

    while True:
      all_ok = True
      for inst in get_lb_status():
        if inst.instance_id in old_insts and inst.state == 'OutOfService' and inst.reason_code == 'ELB':
          all_ok = False
          break

      if all_ok:
        break

      sleep(1)
      status_tick()

    old_insts = None

  get_elb_conn().deregister_instances(LB_NAME, new_ids)
  
  added_to_lb = False
  
  print "New instances removed from LB"

def term():
  global added_to_lb
  
  if added_to_lb:
    revert_lb()

  for instance in instances:
    instance.terminate()
    
  print "Instances Terminated"

def action_loop():
  print "What would you like to do? [help]"

  inp = raw_input('> ').strip().lower()
 
  if not inp or inp == 'help':
    print "[term] Terminate Newly Created Instances"
    print "[add] Add Newly Created Instances to LB"
    print "[remove] Remove Old Instances from LB"
    print "[status] Get LB Status"
    print "[revert] Revert LB to Original Instances"
    print "[quit] Quit"
    print ""
    print "General Pattern: [add] -> [remove] -> [quit]"

  elif inp == 'quit':
    sys.exit(0)

  elif inp == 'term':
    term()

  elif inp == 'revert':
    revert_lb()

  elif inp == 'add':
    add_to_lb()

  elif inp == 'remove':
    remove_old_from_lb()

  elif inp == 'status':
    print_lb_status()

if __name__ == "__main__":
  while True:
    print ""
    action_loop()
