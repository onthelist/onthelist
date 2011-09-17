from boto.ec2.connection import EC2Connection
from boto.ec2.elb import ELBConnection


from aws_keys import *

def get_conn(conn=EC2Connection(ACCESS, SECRET)):
  return conn

def get_elb_conn(conn=ELBConnection(ACCESS, SECRET)):
  return conn
