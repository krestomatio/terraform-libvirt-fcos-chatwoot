Terraform module for creating a [Chatwoot customer engagement suite](https://github.com/chatwoot/chatwoot) using [Fedora CoreOS](https://docs.fedoraproject.org/en-US/fedora-coreos/), and [Libvirt](https://libvirt.org/).

## Dependencies
The following are the dependencies to create the VM with this module:
* [libvirt](https://libvirt.org/)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.0 |
| <a name="requirement_ct"></a> [ct](#requirement\_ct) | 0.11.0 |
| <a name="requirement_libvirt"></a> [libvirt](#requirement\_libvirt) | ~> 0.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_butane_snippet_install_certbot"></a> [butane\_snippet\_install\_certbot](#module\_butane\_snippet\_install\_certbot) | krestomatio/butane-snippets/ct//modules/certbot | 0.0.12 |
| <a name="module_chatwoot"></a> [chatwoot](#module\_chatwoot) | krestomatio/fcos/libvirt | 0.0.28 |

## Resources

| Name | Type |
|------|------|
| [template_file.butane_snippet_install_chatwoot](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_rpms"></a> [additional\_rpms](#input\_additional\_rpms) | Additional rpms to install during boot using rpm-ostree, along with any pre or post command | <pre>object(<br>    {<br>      cmd_pre  = optional(list(string), [])<br>      list     = optional(list(string), [])<br>      cmd_post = optional(list(string), [])<br>    }<br>  )</pre> | <pre>{<br>  "cmd_post": [],<br>  "cmd_pre": [],<br>  "list": []<br>}</pre> | no |
| <a name="input_autostart"></a> [autostart](#input\_autostart) | Autostart with libvirt host | `bool` | `null` | no |
| <a name="input_backup_volume_pool"></a> [backup\_volume\_pool](#input\_backup\_volume\_pool) | Node default backup volume pool | `string` | `null` | no |
| <a name="input_backup_volume_size"></a> [backup\_volume\_size](#input\_backup\_volume\_size) | Node default backup volume size in bytes | `number` | `null` | no |
| <a name="input_butane_snippets_additional"></a> [butane\_snippets\_additional](#input\_butane\_snippets\_additional) | Additional butane snippets | `list(string)` | `[]` | no |
| <a name="input_certbot"></a> [certbot](#input\_certbot) | Certbot config | <pre>object(<br>    {<br>      agree_tos    = bool<br>      staging      = optional(bool)<br>      email        = string<br>      http_01_port = optional(number)<br>    }<br>  )</pre> | `null` | no |
| <a name="input_chatwoot_envvars"></a> [chatwoot\_envvars](#input\_chatwoot\_envvars) | Environment variables for chatwoot | `map(string)` | n/a | yes |
| <a name="input_chatwoot_image"></a> [chatwoot\_image](#input\_chatwoot\_image) | Chatwoot container image | <pre>object(<br>    {<br>      name    = optional(string, "docker.io/chatwoot/chatwoot")<br>      version = optional(string, "latest")<br>    }<br>  )</pre> | <pre>{<br>  "name": "docker.io/chatwoot/chatwoot",<br>  "version": "latest"<br>}</pre> | no |
| <a name="input_cidr_ip_address"></a> [cidr\_ip\_address](#input\_cidr\_ip\_address) | CIDR IP Address. Ex: 192.168.1.101/24 | `string` | `null` | no |
| <a name="input_cpu_mode"></a> [cpu\_mode](#input\_cpu\_mode) | Libvirt default cpu mode for VMs | `string` | `null` | no |
| <a name="input_data_volume_pool"></a> [data\_volume\_pool](#input\_data\_volume\_pool) | Node default data volume pool | `string` | `null` | no |
| <a name="input_data_volume_size"></a> [data\_volume\_size](#input\_data\_volume\_size) | Node default data volume size in bytes | `number` | `null` | no |
| <a name="input_etc_hosts"></a> [etc\_hosts](#input\_etc\_hosts) | /etc/host list | <pre>list(<br>    object(<br>      {<br>        ip       = string<br>        hostname = string<br>        fqdn     = string<br>      }<br>    )<br>  )</pre> | `null` | no |
| <a name="input_etc_hosts_extra"></a> [etc\_hosts\_extra](#input\_etc\_hosts\_extra) | /etc/host extra block | `string` | `null` | no |
| <a name="input_external_fqdn"></a> [external\_fqdn](#input\_external\_fqdn) | FQDN to access Chatwoot mail | `string` | n/a | yes |
| <a name="input_fqdn"></a> [fqdn](#input\_fqdn) | Node FQDN | `string` | n/a | yes |
| <a name="input_ignition_pool"></a> [ignition\_pool](#input\_ignition\_pool) | Default ignition files pool | `string` | `null` | no |
| <a name="input_interface_name"></a> [interface\_name](#input\_interface\_name) | Network interface name | `string` | `null` | no |
| <a name="input_keymap"></a> [keymap](#input\_keymap) | Keymap | `string` | `null` | no |
| <a name="input_log_volume_pool"></a> [log\_volume\_pool](#input\_log\_volume\_pool) | Node default log volume pool | `string` | `null` | no |
| <a name="input_log_volume_size"></a> [log\_volume\_size](#input\_log\_volume\_size) | Node default log volume size in bytes | `number` | `null` | no |
| <a name="input_mac"></a> [mac](#input\_mac) | Mac address | `string` | `null` | no |
| <a name="input_machine"></a> [machine](#input\_machine) | The machine type, you normally won't need to set this unless you are running on a platform that defaults to the wrong machine type for your template | `string` | `null` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Node default memory in MiB | `number` | `512` | no |
| <a name="input_nameservers"></a> [nameservers](#input\_nameservers) | List of nameservers for VMs | `list(string)` | `null` | no |
| <a name="input_network_bridge"></a> [network\_bridge](#input\_network\_bridge) | Libvirt default network bridge name for VMs | `string` | `null` | no |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | Libvirt default network id for VMs | `string` | `null` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Libvirt default network name for VMs | `string` | `null` | no |
| <a name="input_nginx_command"></a> [nginx\_command](#input\_nginx\_command) | Nginx container command | `list(string)` | `[]` | no |
| <a name="input_nginx_cpus_limit"></a> [nginx\_cpus\_limit](#input\_nginx\_cpus\_limit) | Number of CPUs to limit the nginx container | `number` | `0` | no |
| <a name="input_nginx_envvars"></a> [nginx\_envvars](#input\_nginx\_envvars) | Environment variables for nginx | `map(string)` | `{}` | no |
| <a name="input_nginx_image"></a> [nginx\_image](#input\_nginx\_image) | Nginx container image | <pre>object(<br>    {<br>      name    = optional(string, "docker.io/nginx")<br>      version = optional(string, "1.25")<br>    }<br>  )</pre> | <pre>{<br>  "name": "docker.io/nginx",<br>  "version": "1.25"<br>}</pre> | no |
| <a name="input_nginx_memory_limit"></a> [nginx\_memory\_limit](#input\_nginx\_memory\_limit) | Amount of memory to limit the nginx container | `string` | `""` | no |
| <a name="input_nginx_server_conf"></a> [nginx\_server\_conf](#input\_nginx\_server\_conf) | Nginx server.conf. If not set, a default server.conf is used | `string` | `null` | no |
| <a name="input_periodic_updates"></a> [periodic\_updates](#input\_periodic\_updates) | Only reboot for updates during certain timeframes<br>{<br>  time\_zone = "localtime"<br>  windows = [<br>    {<br>      days           = ["Sat"],<br>      start\_time     = "23:30",<br>      length\_minutes = "60"<br>    },<br>    {<br>      days           = ["Sun"],<br>      start\_time     = "00:30",<br>      length\_minutes = "60"<br>    }<br>  ]<br>} | <pre>object(<br>    {<br>      time_zone = optional(string, "")<br>      windows = list(<br>        object(<br>          {<br>            days           = list(string)<br>            start_time     = string<br>            length_minutes = string<br>          }<br>        )<br>      )<br>    }<br>  )</pre> | `null` | no |
| <a name="input_postgres_command"></a> [postgres\_command](#input\_postgres\_command) | Postgres container command | `list(string)` | `[]` | no |
| <a name="input_postgres_cpus_limit"></a> [postgres\_cpus\_limit](#input\_postgres\_cpus\_limit) | Number of CPUs to limit the postgres container | `number` | `0` | no |
| <a name="input_postgres_envvars"></a> [postgres\_envvars](#input\_postgres\_envvars) | Environment variables for postgres | `map(string)` | n/a | yes |
| <a name="input_postgres_image"></a> [postgres\_image](#input\_postgres\_image) | Postgres container image | <pre>object(<br>    {<br>      name    = optional(string, "docker.io/postgres")<br>      version = optional(string, "16")<br>    }<br>  )</pre> | <pre>{<br>  "name": "docker.io/postgres",<br>  "version": "16"<br>}</pre> | no |
| <a name="input_postgres_memory_limit"></a> [postgres\_memory\_limit](#input\_postgres\_memory\_limit) | Amount of memory to limit the postgres container | `string` | `""` | no |
| <a name="input_rails_command"></a> [rails\_command](#input\_rails\_command) | Rails command container command | `list(string)` | <pre>[<br>  "bundle",<br>  "exec",<br>  "rails",<br>  "s",<br>  "-p",<br>  "3000",<br>  "-b",<br>  "0.0.0.0"<br>]</pre> | no |
| <a name="input_rails_cpus_limit"></a> [rails\_cpus\_limit](#input\_rails\_cpus\_limit) | Number of CPUs to limit the rails container | `number` | `0` | no |
| <a name="input_rails_memory_limit"></a> [rails\_memory\_limit](#input\_rails\_memory\_limit) | Amount of memory to limit the rails container | `string` | `""` | no |
| <a name="input_redis_command"></a> [redis\_command](#input\_redis\_command) | Redis container command | `list(string)` | <pre>[<br>  "bash",<br>  "-c",<br>  "\"redis-server --requirepass \\$REDIS_PASSWORD\""<br>]</pre> | no |
| <a name="input_redis_cpus_limit"></a> [redis\_cpus\_limit](#input\_redis\_cpus\_limit) | Number of CPUs to limit the redis container | `number` | `0` | no |
| <a name="input_redis_envvars"></a> [redis\_envvars](#input\_redis\_envvars) | Environment variables for redis | `map(string)` | n/a | yes |
| <a name="input_redis_image"></a> [redis\_image](#input\_redis\_image) | Redis container image | <pre>object(<br>    {<br>      name    = optional(string, "docker.io/redis")<br>      version = optional(string, "7")<br>    }<br>  )</pre> | <pre>{<br>  "name": "docker.io/redis",<br>  "version": "7"<br>}</pre> | no |
| <a name="input_redis_memory_limit"></a> [redis\_memory\_limit](#input\_redis\_memory\_limit) | Amount of memory to limit the redis container | `string` | `""` | no |
| <a name="input_registry_login"></a> [registry\_login](#input\_registry\_login) | Login to a container registry server | <pre>object(<br>    {<br>      username = string<br>      password = string<br>      server   = string<br>    }<br>  )</pre> | `null` | no |
| <a name="input_rollout_wariness"></a> [rollout\_wariness](#input\_rollout\_wariness) | Wariness to update, 1.0 (very cautious) to 0.0 (very eager) | `string` | `null` | no |
| <a name="input_root_base_volume_name"></a> [root\_base\_volume\_name](#input\_root\_base\_volume\_name) | Node default base root volume name | `string` | n/a | yes |
| <a name="input_root_base_volume_pool"></a> [root\_base\_volume\_pool](#input\_root\_base\_volume\_pool) | Node default base root volume pool | `string` | `null` | no |
| <a name="input_root_volume_pool"></a> [root\_volume\_pool](#input\_root\_volume\_pool) | Node default root volume pool | `string` | `null` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | Node default root volume size in bytes | `number` | `null` | no |
| <a name="input_sidekiq_command"></a> [sidekiq\_command](#input\_sidekiq\_command) | Sidekiq container command | `list(string)` | <pre>[<br>  "bundle",<br>  "exec",<br>  "sidekiq",<br>  "-C",<br>  "config/sidekiq.yml"<br>]</pre> | no |
| <a name="input_sidekiq_cpus_limit"></a> [sidekiq\_cpus\_limit](#input\_sidekiq\_cpus\_limit) | Number of CPUs to limit the sidekiq container | `number` | `0` | no |
| <a name="input_sidekiq_memory_limit"></a> [sidekiq\_memory\_limit](#input\_sidekiq\_memory\_limit) | Amount of memory to limit the sidekiq container | `string` | `""` | no |
| <a name="input_ssh_authorized_key"></a> [ssh\_authorized\_key](#input\_ssh\_authorized\_key) | Authorized ssh key for core user | `string` | n/a | yes |
| <a name="input_super_admin_allowed_entries"></a> [super\_admin\_allowed\_entries](#input\_super\_admin\_allowed\_entries) | Allow only this entries to super\_admin subpath | `list(string)` | `[]` | no |
| <a name="input_sync_time_with_host"></a> [sync\_time\_with\_host](#input\_sync\_time\_with\_host) | Sync guest time with the kvm host | `bool` | `null` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Timezone for VMs as listed by `timedatectl list-timezones` | `string` | `null` | no |
| <a name="input_vcpu"></a> [vcpu](#input\_vcpu) | Node default vcpu count | `number` | `null` | no |
| <a name="input_wait_for_lease"></a> [wait\_for\_lease](#input\_wait\_for\_lease) | Wait for network lease | `bool` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## [About Krestomatio](https://krestomatio.com/about)
[Krestomatio is a managed service for Moodle™ e-learning platforms](https://krestomatio.com/). It allows you to have open-source instances managed by a service optimized for Moodle™, complete with an additional plugin pack and customization options.
