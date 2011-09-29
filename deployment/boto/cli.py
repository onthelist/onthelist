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

with open('../initInstance.sh') as f:
  init_script = f.read()

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
    user_data=init_script,
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

termed_old = False
def term_old():
  global old_insts, termed_old, added_to_lb

  if not added_to_lb:
    print "Can't kill the old ones until you have added the new ones."
    return

  if not old_insts:
    print "Remove the old ones before terminating them."
    return

  get_conn().terminate_instances(old_insts)
  termed_old = True

  print "Terminated Old Instances"

def revert_lb():
  global added_to_lb, old_insts, termed_old
  
  if termed_old:
    print "Too late, already terminated old instances."
    return False

  if not added_to_lb:
    print "Never Added Instances, Nothing to Revert"
    return True

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
  return True

def term():
  global added_to_lb, termed_old

  if termed_old:
    print "You can't terminate both the old and new instances."
    return
  
  if added_to_lb:
    if not revert_lb():
      return

  for instance in instances:
    instance.terminate()
    
  print "Instances Terminated"

def action_loop():
  print "What would you like to do? [help]"

  inp = raw_input('> ').strip().lower()
 
  if not inp or inp == 'help':
    print "[term] Terminate Newly Created Instances"
    print "[term_old] Terminate Old Instances"
    print "[add] Add Newly Created Instances to LB"
    print "[remove] Remove Old Instances from LB"
    print "[status] Get LB Status"
    print "[revert] Revert LB to Original Instances"
    print "[quit] Quit"
    print ""
    print "General Pattern: [add] -> [remove] -> [term_old] -> [quit]"

  elif inp == 'quit':
    sys.exit(0)

  elif inp == 'term':
    term()

  elif inp == 'term_old':
    term_old()
  
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
