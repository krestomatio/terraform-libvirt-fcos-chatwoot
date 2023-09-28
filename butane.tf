data "template_file" "butane_snippet_install_chatwoot" {
  template = <<TEMPLATE
---
variant: fcos
version: 1.4.0
storage:
  files:
    # pkg dependencies to be installed by additional-rpms.service
    - path: /var/lib/additional-rpms.list
      overwrite: false
      append:
        - inline: |
            firewalld
    - path: ${local.postgres_env_file}
      mode: 0640
      overwrite: true
      contents:
        inline: |
          %{~for var, value in var.postgres_envvars~}
          ${var}=${value}
          %{~endfor~}
    - path: ${local.redis_env_file}
      mode: 0640
      overwrite: true
      contents:
        inline: |
          %{~for var, value in var.redis_envvars~}
          ${var}=${value}
          %{~endfor~}
    %{~if var.registry_login != null~}
    - path: /usr/local/bin/registry-login.sh
      mode: 0750
      overwrite: true
      contents:
        inline: |
          #!/bin/bash -e

          /usr/bin/podman login ${var.registry_login.server} -u ${var.registry_login.username} -p ${var.registry_login.password} --authfile /root/.docker/config.json
    %{~endif~}
    - path: ${local.chatwoot_env_file}
      mode: 0640
      overwrite: true
      contents:
        inline: |
          %{~for var, value in var.chatwoot_envvars~}
          ${var}=${value}
          %{~endfor~}
    - path: ${local.nginx_env_file}
      mode: 0640
      overwrite: true
      contents:
        inline: |
          %{~for var, value in var.nginx_envvars~}
          ${var}=${value}
          %{~endfor~}
    - path: ${local.nginx_server_conf_file}
      mode: 0640
      overwrite: true
      contents:
        inline: |
          %{~if var.nginx_server_conf != null~}
          ${indent(10, var.nginx_server_conf)}
          %{~else~}
          server_tokens off;

          upstream backend {
            zone upstreams 64K;
            server 127.0.0.1:3000;
            keepalive 32;
          }

          map $http_upgrade $connection_upgrade {
            default upgrade;
            '' close;
          }

          server {
            listen 80 ${var.ngxin_proxy_protocol != null ? "proxy_protocol" : ""};
            listen [::]:80 ${var.ngxin_proxy_protocol != null ? "proxy_protocol" : ""};
            http2  on;
            server_name ${var.external_fqdn} www.${var.external_fqdn};

            access_log /var/log/nginx/chatwoot_access_80.log;
            error_log /var/log/nginx/chatwoot_error_80.log;

            %{~if local.tls~}
            return 301 https://${var.external_fqdn}$request_uri;
            %{~else~}
            %{~if var.ngxin_proxy_protocol != null~}
            %{~for real_ip_from in var.ngxin_proxy_protocol.real_ip_from~}
            set_real_ip_from ${real_ip_from};
            %{~endfor~}
            real_ip_header proxy_protocol;

            %{~endif~}
            location / {
              proxy_pass http://backend;
              proxy_redirect off;

              proxy_pass_header Authorization;
              proxy_set_header Host $host;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection $connection_upgrade;

              client_max_body_size 0;
              proxy_read_timeout 36000s;
            }

            %{~if var.super_admin_allowed_entries != []~}
            location ~* ^/(super_admin|monitoring) {
              proxy_pass http://backend;
              %{~for allowed_entry in var.super_admin_allowed_entries~}
              allow ${allowed_entry};
              %{~endfor~}
              deny all;
            }
            %{~endif~}
            %{~endif~}
          }

          %{~if local.tls~}
          server {
            listen 443 ssl reuseport ${var.ngxin_proxy_protocol != null ? "proxy_protocol" : ""};
            listen [::]:443 ssl reuseport ${var.ngxin_proxy_protocol != null ? "proxy_protocol" : ""};
            http2  on;
            server_name ${var.external_fqdn} www.${var.external_fqdn};

            %{~if var.ngxin_proxy_protocol != null~}
            %{~for real_ip_from in var.ngxin_proxy_protocol.real_ip_from~}
            set_real_ip_from ${real_ip_from};
            %{~endfor~}
            real_ip_header proxy_protocol;

            %{~endif~}
            underscores_in_headers on;

            access_log /var/log/nginx/chatwoot_access_443.log;
            error_log /var/log/nginx/chatwoot_error_443.log;

            location / {
              proxy_pass http://backend;
              proxy_redirect off;

              proxy_pass_header Authorization;
              proxy_set_header Host $host;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-Ssl on; # Optional
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection $connection_upgrade;

              client_max_body_size 0;
              proxy_read_timeout 36000s;
              %{~if var.super_admin_allowed_entries != []~}

              location ~* ^/(super_admin|monitoring) {
                proxy_pass http://backend;
                %{~for allowed_entry in var.super_admin_allowed_entries~}
                allow ${allowed_entry};
                %{~endfor~}
                deny all;
              }
              %{~endif~}
            }

            ssl_certificate /etc/nginx/ssl/fullchain.pem;
            ssl_certificate_key /etc/nginx/ssl/privkey.pem;
            ssl_protocols TLSv1.2 TLSv1.3;
            ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
            ssl_prefer_server_ciphers off;
            ssl_dhparam /etc/nginx/ssl/dhparam.pem;
            ssl_early_data on;
            ssl_buffer_size 4k;
            ssl_session_cache shared:SSL:10m;
            ssl_session_timeout 1d;
            add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
          }
          %{~endif~}
          %{~endif~}
    - path: /usr/local/bin/chatwoot-installer.sh
      mode: 0754
      overwrite: true
      contents:
        inline: |
          #!/bin/bash -e
          # vars

          ## firewalld rules
          if ! systemctl is-active firewalld &> /dev/null
          then
            echo "Enabling firewalld..."
            systemctl restart dbus.service
            restorecon -rv /etc/firewalld
            systemctl enable --now firewalld
            echo "Firewalld enabled..."
          fi
          # Add firewalld rules
          echo "Adding firewalld rules..."
          firewall-cmd --zone=public --permanent --add-port=${local.port}/tcp
          # firewall-cmd --zone=public --add-masquerade
          firewall-cmd --reload
          echo "Firewalld rules added..."

          # selinux context to data dir
          mkdir -p "${local.data_volume_path}" "${local.postgres_data_volume_path}" "${local.redis_data_volume_path}" "${local.chatwoot_data_volume_path}" "${local.chatwoot_config_path}" "${local.postgres_config_path}" "${local.redis_config_path}" "${local.nginx_config_path}"
          chcon -Rt svirt_sandbox_file_t "${local.data_volume_path}" "${local.postgres_data_volume_path}" "${local.redis_data_volume_path}" "${local.chatwoot_data_volume_path}" "${local.chatwoot_config_path}" "${local.postgres_config_path}" "${local.redis_config_path}" "${local.nginx_config_path}"

          # install
          echo "Installing postgres service..."
          podman kill postgres 2>/dev/null || echo
          podman rm postgres 2>/dev/null || echo
          podman create --pull never --rm --restart on-failure --stop-timeout ${local.systemd_stop_timeout} \
            --network host \
            %{~if var.postgres_cpus_limit > 0~}
            --cpus ${var.postgres_cpus_limit} \
            %{~endif~}
            %{~if var.postgres_memory_limit != ""~}
            --memory ${var.postgres_memory_limit} \
            %{~endif~}
            --env-file ${local.postgres_env_file} \
            --volume /etc/localtime:/etc/localtime:ro \
            --volume "${local.postgres_data_volume_path}:/var/lib/postgresql/data" \
            --name postgres ${local.postgres_image} ${join(" ", var.postgres_command)}
          podman generate systemd --new \
            --restart-sec 15 \
            --start-timeout 180 \
            --stop-timeout ${local.systemd_stop_timeout} \
            --after chatwoot-images-pull.service \
            --name postgres > /etc/systemd/system/postgres.service
          systemctl daemon-reload
          systemctl enable --now postgres.service
          echo "postgres service installed..."

          echo "Installing redis service..."
          podman kill redis 2>/dev/null || echo
          podman rm redis 2>/dev/null || echo
          podman create --pull never --rm --restart on-failure --stop-timeout ${local.systemd_stop_timeout} \
            --network host \
            %{~if var.redis_cpus_limit > 0~}
            --cpus ${var.redis_cpus_limit} \
            %{~endif~}
            %{~if var.redis_memory_limit != ""~}
            --memory ${var.redis_memory_limit} \
            %{~endif~}
            --env-file ${local.redis_env_file} \
            --volume /etc/localtime:/etc/localtime:ro \
            --volume "${local.redis_data_volume_path}:/data" \
            --name redis ${local.redis_image} ${join(" ", var.redis_command)}
          podman generate systemd --new \
            --restart-sec 15 \
            --start-timeout 180 \
            --stop-timeout ${local.systemd_stop_timeout} \
            --after chatwoot-images-pull.service \
            --name redis > /etc/systemd/system/redis.service
          systemctl daemon-reload
          systemctl enable --now redis.service
          echo "redis service installed..."

          echo "Preparing rails service..."
          podman kill rails-prepare 2>/dev/null || echo
          podman rm rails-prepare 2>/dev/null || echo
          podman run --pull never --rm \
            --network host \
            --env-file ${local.chatwoot_env_file} \
            --volume /etc/localtime:/etc/localtime:ro \
            --volume "${local.chatwoot_data_volume_path}:/app/storage" \
            --entrypoint docker/entrypoints/rails.sh \
            --name rails-prepare ${local.chatwoot_image} bundle exec rails db:chatwoot_prepare
          echo "rails service prepared..."

          echo "Installing rails service..."
          podman kill rails 2>/dev/null || echo
          podman rm rails 2>/dev/null || echo
          podman create --pull never --rm --restart on-failure --stop-timeout ${local.systemd_stop_timeout} \
            --network host \
            %{~if var.rails_cpus_limit > 0~}
            --cpus ${var.rails_cpus_limit} \
            %{~endif~}
            %{~if var.rails_memory_limit != ""~}
            --memory ${var.rails_memory_limit} \
            %{~endif~}
            --env-file ${local.chatwoot_env_file} \
            --volume /etc/localtime:/etc/localtime:ro \
            --volume "${local.chatwoot_data_volume_path}:/app/storage" \
            --entrypoint docker/entrypoints/rails.sh \
            --name rails ${local.chatwoot_image} ${join(" ", var.rails_command)}
          podman generate systemd --new \
            --restart-sec 15 \
            --start-timeout 180 \
            --stop-timeout ${local.systemd_stop_timeout} \
            --after chatwoot-images-pull.service \
            --after postgres.service \
            --after redis.service \
            --requires postgres.service \
            --requires redis.service \
            --name rails > /etc/systemd/system/rails.service
          systemctl daemon-reload
          systemctl enable --now rails.service
          echo "rails service installed..."

          echo "Installing sidekiq service..."
          podman kill sidekiq 2>/dev/null || echo
          podman rm sidekiq 2>/dev/null || echo
          podman create --pull never --rm --restart on-failure --stop-timeout ${local.systemd_stop_timeout} \
            --network host \
            %{~if var.sidekiq_cpus_limit > 0~}
            --cpus ${var.sidekiq_cpus_limit} \
            %{~endif~}
            %{~if var.sidekiq_memory_limit != ""~}
            --memory ${var.sidekiq_memory_limit} \
            %{~endif~}
            --env-file ${local.chatwoot_env_file} \
            --volume /etc/localtime:/etc/localtime:ro \
            --volume "${local.chatwoot_data_volume_path}:/app/storage" \
            --entrypoint docker/entrypoints/rails.sh \
            --name sidekiq ${local.chatwoot_image} ${join(" ", var.sidekiq_command)}
          podman generate systemd --new \
            --restart-sec 15 \
            --start-timeout 180 \
            --stop-timeout ${local.systemd_stop_timeout} \
            --after chatwoot-images-pull.service \
            --after postgres.service \
            --after redis.service \
            --requires postgres.service \
            --requires redis.service \
            --name sidekiq > /etc/systemd/system/sidekiq.service
          systemctl daemon-reload
          systemctl enable --now sidekiq.service
          echo "sidekiq service installed..."

          echo "Installing nginx service..."
          echo "Genarating dhparam..."
          if ! test -f "${local.nginx_tls_path}/dhparam.pem"; then
            openssl dhparam -out "${local.nginx_tls_path}/dhparam.pem" 2048
          fi
          chcon -t svirt_sandbox_file_t "${local.nginx_tls_path}/dhparam.pem"
          echo "${local.nginx_tls_path}/dhparam.pem generated..."
          podman kill nginx 2>/dev/null || echo
          podman rm nginx 2>/dev/null || echo
          podman create --pull never --rm --restart on-failure --stop-timeout ${local.systemd_stop_timeout} \
            --network host \
            %{~if var.nginx_cpus_limit > 0~}
            --cpus ${var.nginx_cpus_limit} \
            %{~endif~}
            %{~if var.nginx_memory_limit != ""~}
            --memory ${var.nginx_memory_limit} \
            %{~endif~}
            --env-file ${local.nginx_env_file} \
            --volume /etc/localtime:/etc/localtime:ro \
            --volume "${local.nginx_server_conf_file}:/etc/nginx/conf.d/90-server.conf" \
            --volume "${local.nginx_tls_path}:/etc/nginx/ssl" \
            --name nginx ${local.nginx_image} ${join(" ", var.nginx_command)}
          podman generate systemd --new \
            --restart-sec 15 \
            --start-timeout 180 \
            --stop-timeout ${local.systemd_stop_timeout} \
            --after chatwoot-images-pull.service \
            --after rails.service \
            --wants rails.service \
            --name nginx > /etc/systemd/system/nginx.service
          systemctl daemon-reload
          systemctl enable --now nginx.service
          echo "nginx service installed..."
systemd:
  units:
    - name: chatwoot-images-pull.service
      enabled: true
      contents: |
        [Unit]
        Description="Pull chatwoot image"
        Wants=network-online.target
        After=network-online.target
        After=additional-rpms.service
        Requires=additional-rpms.service
        Before=install-chatwoot.service
        Before=postgres.service
        Before=redis.service
        Before=rails.service
        Before=sidekiq.service

        [Service]
        Type=oneshot
        RemainAfterExit=yes
        Restart=no
        TimeoutStartSec=90
        %{~if var.registry_login != null~}
        ExecStart=/usr/local/bin/registry-login.sh
        %{~endif~}
        ExecStart=/usr/bin/podman pull ${local.postgres_image}
        ExecStart=/usr/bin/podman pull ${local.redis_image}
        ExecStart=/usr/bin/podman pull ${local.chatwoot_image}
        ExecStart=/usr/bin/podman pull ${local.nginx_image}

        [Install]
        WantedBy=multi-user.target
    - name: install-chatwoot.service
      enabled: true
      contents: |
        [Unit]
        Description=Install chatwoot
        # We run before `zincati.service` to avoid conflicting rpm-ostree
        # transactions.
        Before=zincati.service
        Wants=network-online.target
        After=network-online.target
        After=additional-rpms.service
        After=install-certbot.service
        After=chatwoot-images-pull.service
        Requires=additional-rpms.service
        Requires=chatwoot-images-pull.service
        ConditionPathExists=/usr/local/bin/chatwoot-installer.sh
        ConditionPathExists=!/var/lib/%N.done

        [Service]
        Type=oneshot
        RemainAfterExit=yes
        Restart=no
        TimeoutStartSec=180
        ExecStart=/usr/local/bin/chatwoot-installer.sh
        ExecStart=/bin/touch /var/lib/%N.done

        [Install]
        WantedBy=multi-user.target
TEMPLATE
}

module "butane_snippet_install_certbot" {
  count = var.certbot != null ? 1 : 0

  source  = "krestomatio/butane-snippets/ct//modules/certbot"
  version = "0.0.12"

  domain       = var.external_fqdn
  http_01_port = var.certbot.http_01_port
  post_hook    = local.post_hook
  agree_tos    = var.certbot.agree_tos
  staging      = var.certbot.staging
  email        = var.certbot.email
}
