######################### values #########################
locals {
  #### module ####
  # certbot
  certbot = null
  # certbot = {
  #   staging      = true
  #   agree_tos    = true
  #   http_01_port = 8888
  #   email        = "info@example.com"
  # }

  # chatwoot
  external_fqdn         = "chatwoot.example.com"
  rails_cpus_limit      = 0.5
  rails_memory_limit    = "1000m"
  sidekiq_cpus_limit    = 0.5
  sidekiq_memory_limit  = "1000m"
  redis_cpus_limit      = 0.200
  redis_memory_limit    = "500m"
  postgres_cpus_limit   = 0.5
  postgres_memory_limit = "750m"
  nginx_cpus_limit      = 0.200
  nginx_memory_limit    = "250m"
  postgres_password     = "secret"
  redis_password        = "secret"
  chatwoot_envvars = {
    NODE_ENV          = "production"
    RAILS_ENV         = "production"
    INSTALLATION_ENV  = "docker"
    SECRET_KEY_BASE   = "secret"
    POSTGRES_HOST     = "127.0.0.1"
    POSTGRES_PASSWORD = local.postgres_password
    POSTGRES_DATABASE = "chatwoot"
    POSTGRES_USERNAME = "chatwoot"
    REDIS_PASSWORD    = local.redis_password
    REDIS_URL         = "redis://127.0.0.1:6379"

  }
  postgres_envvars = {
    POSTGRES_PASSWORD = local.postgres_password
    POSTGRES_DB       = "chatwoot"
    POSTGRES_USER     = "chatwoot"
  }
  redis_envvars = {
    REDIS_PASSWORD = local.redis_password
  }
  # libvirt
  fqdn               = local.external_fqdn
  cidr_ip_address    = "10.10.18.11/24"
  mac                = "50:50:10:10:18:11"
  vcpu               = 2
  memory             = 4096
  root_volume_size   = 1024 * 1024 * 1024 * 10 # in bytes, 10 Gi
  log_volume_size    = 1024 * 1024 * 1024 * 5  # in bytes, 5 Gi
  data_volume_size   = 1024 * 1024 * 1024 * 10 # in bytes, 10 Gi
  backup_volume_size = 1024 * 1024 * 1024 * 10 # in bytes, 10 Gi
  ssh_authorized_key = file(pathexpand("~/.ssh/id_rsa.pub"))
  nameservers        = ["8.8.8.8"]
  timezone           = "America/Costa_Rica"
  keymap             = "latam"
  rollout_wariness   = "0.5"
  additional_rpms = {
    list = ["nano"]
  }
  periodic_updates = {
    time_zone = "localtime"
    windows = [
      {
        days           = ["Sat"],
        start_time     = "23:30",
        length_minutes = "60"
      },
      {
        days           = ["Sun"],
        start_time     = "00:30",
        length_minutes = "60"
      }
    ]
  }
  etc_hosts = [
    {
      ip       = "127.0.0.1"
      hostname = "chatwoot-01"
      fqdn     = "chatwoot-01.example.com"
    },
    {
      ip       = "192.168.0.10"
      hostname = "other-server-01"
      fqdn     = "other-server-01.example.com"
    }
  ]
  #### end module values ####

  # others
  prefix = "chatwoot"

  # network
  net_name      = "libvirt-fcos-${local.prefix}"
  net_cidr_ipv4 = "10.10.18.0/24"
  net_cidr_ipv6 = "2001:db8:ca2:18::/64"

  # image
  image_name           = "terraform-libvirt-fcos-${local.fcos_image_name}"
  fcos_image_version   = "38.20230902.3.0"
  fcos_image_arch      = "x86_64"
  fcos_image_stream    = "stable"
  fcos_image_sha256sum = "09ab10a13330307baefb71e6fcf9f07ce93799aad9ec25185bf59deb3d6c1eb7"
  fcos_image_url       = "https://builds.coreos.fedoraproject.org/prod/streams/${local.fcos_image_stream}/builds/${local.fcos_image_version}/${local.fcos_image_arch}/fedora-coreos-${local.fcos_image_version}-qemu.${local.fcos_image_arch}.qcow2.xz"
  fcos_image_name      = "fcos-${local.fcos_image_stream}-${local.fcos_image_version}-${local.fcos_image_arch}.qcow2"
}

# network
resource "libvirt_network" "libvirt_fcos_base" {
  name      = local.net_name
  mode      = "nat"
  domain    = "cluster.local"
  addresses = [local.net_cidr_ipv4, local.net_cidr_ipv6]
}

# image
resource "null_resource" "fcos_image_download" {
  provisioner "local-exec" {
    command = <<-TEMPLATE
      pushd /tmp
      if [ ! -f "${local.fcos_image_name}" ]; then
        curl -L "${local.fcos_image_url}" -o "${local.fcos_image_name}.xz"
        echo "${local.fcos_image_sha256sum} ${local.fcos_image_name}.xz" | sha256sum -c
        unxz "${local.fcos_image_name}.xz"
      fi
      popd
    TEMPLATE
  }
}

resource "libvirt_volume" "fcos_image" {
  depends_on = [null_resource.fcos_image_download]

  name   = local.image_name
  source = "/tmp/${local.fcos_image_name}"
}

######################## module #########################
module "libvirt_fcos_chatwoot" {
  depends_on = [libvirt_volume.fcos_image]

  source = "../.."

  # certbot
  certbot = local.certbot
  # chatwoot
  external_fqdn         = local.external_fqdn
  rails_cpus_limit      = local.rails_cpus_limit
  rails_memory_limit    = local.rails_memory_limit
  sidekiq_cpus_limit    = local.sidekiq_cpus_limit
  sidekiq_memory_limit  = local.sidekiq_memory_limit
  redis_cpus_limit      = local.redis_cpus_limit
  redis_memory_limit    = local.redis_memory_limit
  postgres_cpus_limit   = local.postgres_cpus_limit
  postgres_memory_limit = local.postgres_memory_limit
  nginx_cpus_limit      = local.nginx_cpus_limit
  nginx_memory_limit    = local.nginx_memory_limit
  chatwoot_envvars      = local.chatwoot_envvars
  postgres_envvars      = local.postgres_envvars
  redis_envvars         = local.redis_envvars
  # libvirt
  fqdn               = local.fqdn
  cidr_ip_address    = local.cidr_ip_address
  mac                = local.mac
  ssh_authorized_key = local.ssh_authorized_key
  nameservers        = local.nameservers
  timezone           = local.timezone
  rollout_wariness   = local.rollout_wariness
  periodic_updates   = local.periodic_updates
  keymap             = local.keymap
  etc_hosts          = local.etc_hosts
  additional_rpms    = local.additional_rpms
  vcpu               = local.vcpu
  memory             = local.memory
  root_volume_size   = local.root_volume_size
  log_volume_size    = local.log_volume_size
  data_volume_size   = local.data_volume_size
  backup_volume_size = local.backup_volume_size

  root_base_volume_name = libvirt_volume.fcos_image.name
  network_id            = libvirt_network.libvirt_fcos_base.id
}
