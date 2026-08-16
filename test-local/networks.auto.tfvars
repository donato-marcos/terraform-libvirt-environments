# networks.auto.tfvars:
networks = [
  {
    name      = "teste-nat"
    mode      = "nat"
    autostart = true

    ipv4_address      = "192.168.49.1"
    ipv4_prefix       = 24
    ipv4_dhcp_enabled = true
    ipv4_dhcp_start   = "192.168.49.10"
    ipv4_dhcp_end     = "192.168.49.200"
  }
]