# vm.auto.tfvars:
vms = {
  # Servidor kubernetes control-plane
  "ubuntu-teste" = {
    os_type        = "linux"
    vcpus          = 3
    current_memory = 4096
    memory         = 4096
    firmware       = "efi"
    video_model    = "virtio"
    graphics       = "spice"
    running        = true
    disks = [
      {
        name     = "os"
        size_gb  = 25
        bootable = true

        backing_store = {
          image  = "ubuntu-26-cloud.x86_64.qcow2"
          format = "qcow2"
        }
      }
    ]
    networks = [
      {
        name           = "teste-nat"
        ipv4_address   = "dhcp"
        ipv6_address   = "dhcp"
        wait_for_lease = true
      }
    ]
  }
}