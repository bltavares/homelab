
[[tcp.services.ssb-shs.loadBalancer.servers]]
  address = "ssb-shs.bltavares.com:8008"
[tcp.routers.ssb-shs]
  entryPoints = ["ssb-shs"]
  rule = "HostSNI(`*`)"
  service = "ssb-shs"

[[tcp.services.ssh-shs-web.loadBalancer.servers]]
  address = "ssb-shs.bltavares.com:8443"
[tcp.routers.ssh-shs-web]
  entryPoints = ["ssl"]
  rule = "HostSNI(`ssb.bltavares.com`) || HostSNIRegexp(`{subdomain:[a-z]+}.ssb.bltavares.com`)"
  service = "ssh-shs-web"
  tls = { passthrough = true }