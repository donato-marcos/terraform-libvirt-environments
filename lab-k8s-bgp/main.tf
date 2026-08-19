module "orchestration" {
  source = "git::https://github.com/donato-marcos/terraform-libvirt-orchestration.git?ref=v1.0.0"

  # Dados de infraestrutura
  networks = var.networks
  vms      = var.vms

  # Configuração do ambiente
  ssh_public      = var.ssh_public
  storage_pool    = var.storage_pool
  image_directory = var.image_directory

  # Templates específicos deste lab
  template_dir = "${path.module}/cloudinit-templates"
}
