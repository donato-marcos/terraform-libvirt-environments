
# Terraform Libvirt Environments

> Ready-to-use lab environments built with **OpenTofu/Terraform + Libvirt/KVM**, using the reusable modules from the `terraform-libvirt-*` repositories.

This repository contains example and lab environments for building heterogeneous virtualized infrastructures with Linux, Windows, and VyOS, including IPv4/IPv6 networking.

The environments are designed to be **declarative, reproducible, and easy to adapt** to another Libvirt/KVM host.

## 🎯 Objective

Provide ready-to-use lab environments that demonstrate how to compose the reusable Terraform/OpenTofu Libvirt modules into complete infrastructures.

An environment defines the actual infrastructure to be created, including:

- Libvirt networks
- Virtual machines
- Virtual disks
- Cloud-init configuration
- Linux/VyOS domains
- Windows domains
- IPv4/IPv6 networking
- NAT and isolated networks

The reusable infrastructure logic is maintained separately in dedicated repositories.

## 🏗 Architecture

The project is organized into two layers:

```text
terraform-libvirt-environments
│
├── Environment configuration
│   ├── Networks
│   ├── Virtual machines
│   ├── Cloud-init customization
│   └── Host-specific configuration
│
└── Reusable modules
    └── terraform-libvirt-orchestration
         │
         ├── terraform-libvirt-network
         ├── terraform-libvirt-volume
         ├── terraform-libvirt-cloudinit
         ├── terraform-libvirt-domain-linux
         └── terraform-libvirt-domain-windows
```

Each reusable module is maintained in its own Git repository and referenced by Git tag.

For example:

```hcl
module "orchestration" {
  source = "git::https://github.com/donato-marcos/terraform-libvirt-orchestration.git?ref=v1.0.0"
}
```

The orchestration module, in turn, consumes the other reusable modules using specific versions.

## 📂 Environments

Each directory represents an independent environment.

Current environments:

```text
terraform-libvirt-environments/
└── lab-example/
    ├── cloudinit-templates/
    │   ├── linux/
    │   └── vyos/
    ├── main.tf
    ├── networks.auto.tfvars
    ├── outputs.tf
    ├── providers.tf
    ├── README.md
    ├── variables.tf
    ├── version.tf
    └── vm.auto.tfvars
```

Additional environments can be added as needed.

Each environment can have its own:

* Network topology
* Virtual machines
* Cloud-init templates
* Libvirt connection
* Storage configuration
* Provider configuration

# 🚀 Getting Started

## Prerequisites

The environment requires:

* Linux host
* QEMU/KVM
* Libvirt
* OpenTofu or Terraform
* A Libvirt storage pool for VM disks
* Base VM images referenced by the environment
* `virtio-win` ISO if Windows VMs are used

The exact requirements may vary depending on the environment being deployed.

---

## Which base images do you need?

There are no universally required base images.

Each environment defines which images are required through the `backing_store.image` attribute in `vm.auto.tfvars`.

For example:

```hcl
"ubuntu-teste" = {
  os_type = "linux"

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
}
```

In this example, the following image must exist in the configured Libvirt storage pool:

```text
ubuntu-26-cloud.x86_64.qcow2
```

### Rule of thumb

Look at:

```text
vm.auto.tfvars
└── vms
    └── <vm>
        └── disks
            └── backing_store
                └── image
```

The images referenced there are the images required by that environment.

If an environment does not define Windows VMs, a Windows base image is not required.

If an environment does not define VyOS VMs, a VyOS base image is not required.

## Cloud-init templates

The reusable Cloud-init module provides default templates for Linux and VyOS.

An environment can provide its own templates when environment-specific configuration is required.

Example:

```text
lab-example/
└── cloudinit-templates/
    ├── linux/
    │   ├── meta-data.yaml.tftpl
    │   ├── network-config.yaml.tftpl
    │   └── user-data.yaml.tftpl
    │
    └── vyos/
        ├── meta-data.yaml.tftpl
        ├── network-config.yaml.tftpl
        └── user-data.yaml.tftpl
```

Environment-specific templates take precedence when provided.

# 📋 Configuration

Before deploying an environment, review its configuration files.

## `networks.auto.tfvars`

Defines the network topology.

Example:

```hcl
networks = [
  {
    name              = "teste-nat"
    mode              = "nat"
    autostart         = true

    ipv4_address      = "192.168.49.1"
    ipv4_prefix       = 24
    ipv4_dhcp_enabled = true
    ipv4_dhcp_start   = "192.168.49.10"
    ipv4_dhcp_end     = "192.168.49.200"
  }
]
```

This file is part of the environment definition and can be versioned.

## `vm.auto.tfvars`

Defines the virtual machines that will be created.

Example:

```hcl
vms = {
  "ubuntu-teste" = {
    os_type        = "linux"
    vcpus          = 3
    current_memory = 4096
    memory         = 4096

    firmware     = "efi"
    video_model  = "virtio"
    graphics     = "spice"
    running      = true

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
```

This file is also part of the environment definition and can be versioned.

## Host-specific configuration

Some values depend on the local Libvirt/KVM host.

Typical examples include:

```hcl
storage_pool    = "default"
libvirt_uri     = "qemu:///system"
image_directory = "/home/user/vm"
```

Review these values before deploying the environment.

If the environment provides an example file, copy it and adjust it for your host.

# 🔐 Secrets and private configuration

Sensitive configuration must not be committed to the repository.

For example:

```text
secrets.auto.tfvars
```

is ignored by Git.

A corresponding example file can be provided:

```text
secrets.auto.tfvars.example
```

The example file should contain only placeholder or non-sensitive values.

# ▶️ Deploying an Environment

Select the environment you want to deploy.

For example:

```bash
cd lab-example
```

Initialize OpenTofu:

```bash
tofu init
```

Validate the configuration:

```bash
tofu validate
```

Review the execution plan:

```bash
tofu plan
```

Apply the environment:

```bash
tofu apply
```

To destroy the environment:

```bash
tofu destroy
```

---

# 🔄 Reproducibility

The reusable modules are referenced using Git tags.

For example:

```text
terraform-libvirt-orchestration → v1.0.0
```

The orchestration module references specific versions of its dependencies.

This means an environment can reproduce the same module versions instead of depending on whatever happens to be present in a local modules directory.

The provider version is also controlled by the OpenTofu lock file:

```text
.terraform.lock.hcl
```

The lock file should be committed to the repository.

# 🔀 Execution Flow

The environment delegates infrastructure creation to the orchestration module.

The orchestration flow is:

```text
Networks
   │
   ▼
Volumes
   │
   ▼
Cloud-init
   │
   ▼
Linux / VyOS Domains
   │
   ▼
Windows Domains
```

More specifically:

1. **Networks**

   * Libvirt networks
   * IPv4/IPv6 configuration
   * DHCP
   * NAT

2. **Volumes**

   * VM disks
   * Backing stores
   * Base images

3. **Cloud-init**

   * Linux
   * VyOS
   * Only when required by the VM configuration

4. **Linux/VyOS domains**

   * KVM domains
   * EFI
   * TPM/SMM where configured
   * Cloud-init

5. **Windows domains**

   * KVM domains
   * VirtIO drivers
   * Windows-specific configuration

# 📤 Outputs

After `tofu apply`, the environment exposes information about the resources that were created.

For example:

```text
provisioned_vms = {
  "ubuntu-teste" = {
    current_memory = 4096

    disks = [
      {
        bootable = true
        size_gb  = 25
        vol_name = "ubuntu-teste-os"
      }
    ]

    memory = 4096

    networks = [
      {
        ipv4_address   = "dhcp"
        ipv6_address   = "dhcp"
        name           = "teste-nat"
        wait_for_lease  = true
      }
    ]

    os_type = "linux"
    running = true
    status  = "running"
    vcpus   = 3
  }
}
```

The `provisioned_vms` output can also be consumed by other tools or automation, such as generating an Ansible inventory.

# ⚠️ Limitations and Design Decisions

| Aspect                 | Detail                                                                               |
| ---------------------- | ------------------------------------------------------------------------------------ |
| **SSH Key**            | Single global key rather than a key per VM                                           |
| **Windows**            | Does not use Cloud-init; VirtIO drivers are provided through an ISO                  |
| **Validation**         | Base images and some external resources are not pre-validated                        |
| **Scalability**        | Designed for personal and lab environments rather than production infrastructure     |
| **Host configuration** | Libvirt URI, storage pools, image paths, and similar settings may need to be adapted |
| **Dependencies**       | Reusable modules are maintained in separate Git repositories                         |

# 📂 Example Host Storage Layout

A possible Libvirt host configuration may look like:

```text
/home/user/vm/
├── ubuntu-26-cloud.x86_64.qcow2
├── Rocky-10-GenericCloud-Base.latest.x86_64.qcow2
├── win2k22gui-custom-image.qcow2
└── vyos-custom-image.qcow2
```

If Windows VMs are used, a VirtIO driver ISO may also be required:

```text
virtio-win-0.1.285.iso
```

The exact image names and paths depend on the environment configuration.

> The files shown above are examples only. Only the base images actually referenced by `vm.auto.tfvars` are required.

# 📚 Reusable Modules

The infrastructure modules are maintained in separate repositories:

| Module                             | Description                                 |
| ---------------------------------- | ------------------------------------------- |
| `terraform-libvirt-network`        | Creates Libvirt networks                    |
| `terraform-libvirt-volume`         | Creates VM storage volumes                  |
| `terraform-libvirt-cloudinit`      | Creates Cloud-init ISOs                     |
| `terraform-libvirt-domain-linux`   | Creates Linux/VyOS KVM domains              |
| `terraform-libvirt-domain-windows` | Creates Windows KVM domains                 |
| `terraform-libvirt-orchestration`  | Composes and orchestrates the modules above |

Each module has its own documentation, versioning, and Git tags.

# 🧪 Typical Use Cases

These environments are intended for scenarios such as:

* Security labs
* VyOS firewall and routing labs
* DMZ and internal network simulations
* Corporate network simulations
* Active Directory environments
* DNS/DHCP laboratories
* IPv4/IPv6 studies
* Kubernetes labs
* Development environments
* Testing infrastructure automation

# 🛠 Technical Requirements

The exact requirements depend on the environment, but generally include:

* OpenTofu `>= 1.11.0`
* Terraform `>= 1.11.0` if using Terraform
* `dmacvicar/libvirt` provider `>= 0.9.1, < 1.0.0`
* QEMU/KVM
* Libvirt
* TPM 2.0 support for environments that require it
* SPICE support for graphical consoles where configured
* VirtIO drivers for Windows environments

The selected provider version is recorded in:

```text
.terraform.lock.hcl
```

# 📜 License

This project is licensed under the MIT License.

> This project prioritizes **clarity, reproducibility, and fidelity to real infrastructure** over generic abstractions.
