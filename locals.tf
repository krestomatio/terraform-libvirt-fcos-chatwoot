locals {
  data_volume_path          = "/var/mnt/data"
  chatwoot_data_volume_path = "/var/mnt/data/chatwoot"
  postgres_data_volume_path = "/var/mnt/data/postgres"
  redis_data_volume_path    = "/var/mnt/data/redis"
  chatwoot_config_path      = "/var/opt/chatwoot"
  postgres_config_path      = "/var/opt/postgres"
  redis_config_path         = "/var/opt/redis"
  nginx_config_path         = "/var/opt/nginx"
  chatwoot_env_file         = "${local.chatwoot_config_path}/.env"
  postgres_env_file         = "${local.postgres_config_path}/.env"
  redis_env_file            = "${local.redis_config_path}/.env"
  nginx_env_file            = "${local.nginx_config_path}/.env"
  nginx_server_conf_file    = "${local.nginx_config_path}/90-server.conf"
  systemd_stop_timeout      = 30
  chatwoot_image            = "${var.chatwoot_image.name}:${var.chatwoot_image.version}"
  postgres_image            = "${var.postgres_image.name}:${var.postgres_image.version}"
  redis_image               = "${var.redis_image.name}:${var.redis_image.version}"
  nginx_image               = "${var.nginx_image.name}:${var.nginx_image.version}"
  tls                       = var.certbot != null ? true : false
  nginx_tls_path            = "${local.nginx_config_path}/ssl/"
  port                      = local.tls ? 443 : 80
  post_hook = {
    path    = "/usr/local/bin/chatwoot-certbot-renew-hook"
    content = <<-TEMPLATE
      #!/bin/bash

      # vars
      container_name=nginx
      cert_folder_path="${local.nginx_tls_path}"
      cert_path="$$${cert_folder_path}/fullchain.pem"
      key_path="$$${cert_folder_path}/privkey.pem"
      proxy_uid="0"
      proxy_gid="0"
      source_cert_folder_path="/etc/letsencrypt/live/${var.external_fqdn}"
      source_cert_path="$$${source_cert_folder_path}/fullchain.pem"
      source_key_path="$$${source_cert_folder_path}/privkey.pem"

      # handle cert correct placement
      # dir
      mkdir -p $$${cert_folder_path}
      # cert
      cp -f "$$${source_cert_path}" "$$${cert_path}"
      # key
      cp -f "$$${source_key_path}" "$$${key_path}"
      # owner
      chown $$${proxy_uid}:$$${proxy_gid} "$$${cert_folder_path}" "$$${cert_path}" "$$${key_path}"
      # permissions
      chmod 0600 "$$${cert_path}" "$$${key_path}"

      # reload signal in container
      if podman ps --format "{{.Names}}" 2> /dev/null | grep -q -w $container_name
      then
        echo "sending reload signal to container: $container_name..."
        podman exec $container_name nginx -s reload
      else
        echo "$container_name container not running"
      fi
    TEMPLATE
  }
}
