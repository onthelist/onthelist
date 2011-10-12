default[:nginx][:version]      = "1.0.8"

default[:nginx][:dir]     = "/etc/nginx"
default[:nginx][:log_dir] = "/var/log/nginx"
default[:nginx][:user]    = "www-server"
default[:nginx][:group]    = "www"
default[:nginx][:binary]  = "/usr/sbin/nginx"

default[:nginx][:gzip] = "on"
default[:nginx][:gzip_http_version] = "1.0"
default[:nginx][:gzip_comp_level] = "2"
default[:nginx][:gzip_proxied] = "any"
default[:nginx][:gzip_types] = [
  "text/plain",
  "text/css",
  "application/x-javascript",
  "application/javascript",
  "text/xml",
  "application/xml",
  "application/xml+rss",
  "text/javascript"
]

default[:nginx][:keepalive]          = "on"
default[:nginx][:keepalive_timeout]  = 65
default[:nginx][:worker_processes]   = cpu[:total]
default[:nginx][:worker_connections] = 2048
default[:nginx][:server_names_hash_bucket_size] = 64

# Don't forget to open new ports in EC2 firewall for internal traffic.
default[:nginx][:apps] = {
  'messaging' => 5857,
  'device' => 4313,
  'log' => 40404,
  'sync' => 6996
}
