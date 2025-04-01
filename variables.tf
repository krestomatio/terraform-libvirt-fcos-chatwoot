# certbot
variable "certbot" {
  type = object(
    {
      agree_tos    = bool
      staging      = optional(bool)
      email        = string
      http_01_port = optional(number)
    }
  )
  description = "Certbot config"
  default     = null
}

# chatwoot
variable "external_fqdn" {
  type        = string
  description = "FQDN to access Chatwoot mail"
}

variable "chatwoot_image" {
  type = object(
    {
      name    = optional(string, "docker.io/chatwoot/chatwoot")
      version = optional(string, "latest")
    }
  )
  description = "Chatwoot container image"
  default = {
    name    = "docker.io/chatwoot/chatwoot"
    version = "latest"
  }
  nullable = false
}

variable "postgres_image" {
  type = object(
    {
      name    = optional(string, "docker.io/pgvector/pgvector")
      version = optional(string, "pg16")
    }
  )
  description = "Postgres container image"
  default = {
    name    = "docker.io/pgvector/pgvector"
    version = "pg16"
  }
  nullable = false
}

variable "redis_image" {
  type = object(
    {
      name    = optional(string, "docker.io/redis")
      version = optional(string, "7")
    }
  )
  description = "Redis container image"
  default = {
    name    = "docker.io/redis"
    version = "7"
  }
  nullable = false
}

variable "nginx_image" {
  type = object(
    {
      name    = optional(string, "docker.io/nginx")
      version = optional(string, "1.25")
    }
  )
  description = "Nginx container image"
  default = {
    name    = "docker.io/nginx"
    version = "1.25"
  }
  nullable = false
}

variable "rails_cpus_limit" {
  type        = number
  description = "Number of CPUs to limit the rails container"
  default     = 0
}

variable "rails_memory_limit" {
  type        = string
  description = "Amount of memory to limit the rails container"
  default     = ""
  nullable    = false
}

variable "sidekiq_cpus_limit" {
  type        = number
  description = "Number of CPUs to limit the sidekiq container"
  default     = 0
}

variable "sidekiq_memory_limit" {
  type        = string
  description = "Amount of memory to limit the sidekiq container"
  default     = ""
  nullable    = false
}

variable "postgres_cpus_limit" {
  type        = number
  description = "Number of CPUs to limit the postgres container"
  default     = 0
}

variable "postgres_memory_limit" {
  type        = string
  description = "Amount of memory to limit the postgres container"
  default     = ""
  nullable    = false
}

variable "redis_cpus_limit" {
  type        = number
  description = "Number of CPUs to limit the redis container"
  default     = 0
}

variable "redis_memory_limit" {
  type        = string
  description = "Amount of memory to limit the redis container"
  default     = ""
  nullable    = false
}

variable "nginx_cpus_limit" {
  type        = number
  description = "Number of CPUs to limit the nginx container"
  default     = 0
}

variable "nginx_memory_limit" {
  type        = string
  description = "Amount of memory to limit the nginx container"
  default     = ""
  nullable    = false
}

variable "chatwoot_envvars" {
  type        = map(string)
  sensitive   = true
  description = "Environment variables for chatwoot"
  nullable    = false
  validation {
    condition = alltrue([
      contains(keys(var.chatwoot_envvars), "POSTGRES_PASSWORD"),
      contains(keys(var.chatwoot_envvars), "REDIS_PASSWORD")
    ])

    error_message = "The map must contain 'POSTGRES_PASSWORD' and 'REDIS_PASSWORD'"
  }
}

variable "postgres_envvars" {
  type        = map(string)
  sensitive   = true
  description = "Environment variables for postgres"
  nullable    = false
  validation {
    condition = alltrue([
      contains(keys(var.postgres_envvars), "POSTGRES_PASSWORD")
    ])

    error_message = "The map must contain 'POSTGRES_PASSWORD'"
  }
}

variable "redis_envvars" {
  type        = map(string)
  sensitive   = true
  description = "Environment variables for redis"
  nullable    = false
  validation {
    condition = alltrue([
      contains(keys(var.redis_envvars), "REDIS_PASSWORD")
    ])

    error_message = "The map must contain 'REDIS_PASSWORD'"
  }
}

variable "nginx_envvars" {
  type        = map(string)
  sensitive   = true
  description = "Environment variables for nginx"
  default     = {}
  nullable    = false
}

variable "nginx_server_conf" {
  type        = string
  description = "Nginx server.conf. If not set, a default server.conf is used"
  default     = null
}

variable "rails_command" {
  type        = list(string)
  description = "Rails command container command"
  default = [
    "bundle",
    "exec",
    "rails",
    "s",
    "-p",
    "3000",
    "-b",
    "0.0.0.0"
  ]
}

variable "sidekiq_command" {
  type        = list(string)
  description = "Sidekiq container command"
  default = [
    "bundle",
    "exec",
    "sidekiq",
    "-C",
    "config/sidekiq.yml"
  ]
}

variable "redis_command" {
  type        = list(string)
  description = "Redis container command"
  default = [
    "bash",
    "-c",
    "\"redis-server --requirepass \\$REDIS_PASSWORD\""
  ]
}

variable "postgres_command" {
  type        = list(string)
  description = "Postgres container command"
  default     = []
  nullable    = false
}

variable "nginx_command" {
  type        = list(string)
  description = "Nginx container command"
  default     = []
  nullable    = false
}

variable "registry_login" {
  type = object(
    {
      username = string
      password = string
      server   = string
    }
  )
  description = "Login to a container registry server"
  default     = null
}

variable "super_admin_allowed_entries" {
  type        = list(string)
  description = "Allow only this entries to super_admin subpath"
  default     = []
  nullable    = false
}

variable "ngxin_proxy_protocol" {
  type = object(
    {
      real_ip_from = optional(list(string), [])
    }
  )
  description = "Enable proxy protocol in nginx"
  default     = null
}

# butane custom
variable "butane_snippets_additional" {
  type        = list(string)
  default     = []
  description = "Additional butane snippets"
  nullable    = false
}

# butane common
variable "ssh_authorized_key" {
  type        = string
  description = "Authorized ssh key for core user"
}

variable "nameservers" {
  type        = list(string)
  description = "List of nameservers for VMs"
  default     = null
}

variable "timezone" {
  type        = string
  description = "Timezone for VMs as listed by `timedatectl list-timezones`"
  default     = null
}

variable "rollout_wariness" {
  type        = string
  description = "Wariness to update, 1.0 (very cautious) to 0.0 (very eager)"
  default     = null
}

variable "periodic_updates" {
  type = object(
    {
      time_zone = optional(string, "")
      windows = list(
        object(
          {
            days           = list(string)
            start_time     = string
            length_minutes = string
          }
        )
      )
    }
  )
  description = <<-TEMPLATE
    Only reboot for updates during certain timeframes
    {
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
  TEMPLATE
  default     = null
}

variable "keymap" {
  type        = string
  description = "Keymap"
  default     = null
}

variable "etc_hosts" {
  type = list(
    object(
      {
        ip       = string
        hostname = string
        fqdn     = string
      }
    )
  )
  description = "/etc/host list"
  default     = null
}

variable "etc_hosts_extra" {
  type        = string
  description = "/etc/host extra block"
  default     = null
}

variable "additional_rpms" {
  type = object(
    {
      cmd_pre  = optional(list(string), [])
      list     = optional(list(string), [])
      cmd_post = optional(list(string), [])
    }
  )
  description = "Additional rpms to install during boot using rpm-ostree, along with any pre or post command"
  default = {
    cmd_pre  = []
    list     = []
    cmd_post = []
  }
  nullable = false
}

variable "interface_name" {
  type        = string
  description = "Network interface name"
  default     = null
}

variable "sync_time_with_host" {
  type        = bool
  description = "Sync guest time with the kvm host"
  default     = null
}

# libvirt node
variable "fqdn" {
  type        = string
  description = "Node FQDN"
}

variable "cidr_ip_address" {
  type        = string
  description = "CIDR IP Address. Ex: 192.168.1.101/24"
  validation {
    condition     = can(cidrhost(var.cidr_ip_address, 1))
    error_message = "Check cidr_ip_address format"
  }
  default = null
}

variable "mac" {
  type        = string
  description = "Mac address"
  default     = null
}

variable "cpu_mode" {
  type        = string
  description = "Libvirt default cpu mode for VMs"
  default     = null
}

variable "vcpu" {
  type        = number
  description = "Node default vcpu count"
  default     = null
}

variable "memory" {
  type        = number
  description = "Node default memory in MiB"
  default     = 512
  nullable    = false
}

variable "machine" {
  type        = string
  description = "The machine type, you normally won't need to set this unless you are running on a platform that defaults to the wrong machine type for your template"
  default     = null
}

variable "root_volume_pool" {
  type        = string
  description = "Node default root volume pool"
  default     = null
}

variable "root_volume_size" {
  type        = number
  description = "Node default root volume size in bytes"
  default     = null
}

variable "root_base_volume_name" {
  type        = string
  description = "Node default base root volume name"
  nullable    = false
}

variable "root_base_volume_pool" {
  type        = string
  description = "Node default base root volume pool"
  default     = null
}

variable "log_volume_pool" {
  type        = string
  description = "Node default log volume pool"
  default     = null
}

variable "log_volume_size" {
  type        = number
  description = "Node default log volume size in bytes"
  default     = null
}

variable "data_volume_pool" {
  type        = string
  description = "Node default data volume pool"
  default     = null
}

variable "data_volume_size" {
  type        = number
  description = "Node default data volume size in bytes"
  default     = null
}

variable "backup_volume_pool" {
  type        = string
  description = "Node default backup volume pool"
  default     = null
}

variable "backup_volume_size" {
  type        = number
  description = "Node default backup volume size in bytes"
  default     = null
}

variable "ignition_pool" {
  type        = string
  description = "Default ignition files pool"
  default     = null
}

variable "wait_for_lease" {
  type        = bool
  description = "Wait for network lease"
  default     = null
}

variable "autostart" {
  type        = bool
  description = "Autostart with libvirt host"
  default     = null
}

variable "network_bridge" {
  type        = string
  description = "Libvirt default network bridge name for VMs"
  default     = null
}

variable "network_id" {
  type        = string
  description = "Libvirt default network id for VMs"
  default     = null
}

variable "network_name" {
  type        = string
  description = "Libvirt default network name for VMs"
  default     = null
}
