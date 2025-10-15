resource "local_file" "docker_compose" {
    filename = "${var.app_directory}/docker-compose.yml"
    content = templatefile("${path.module}/templates/docker-compose.yml.tftpl", {
        pg_db       = var.pg_db
        pg_user     = var.pg_user
        pg_password = random_password.pg_password.result
    })

    depends_on = [
        hcloud_server.tenant_server
    ]
}

resource "local_file" "nginx_config" {
    filename = "${var.app_directory}/nginx.conf"
    content  = templatefile("${path.module}/templates/nginx.conf.tftpl", {
        upstream_port         = "5985"
        upstream_ws_port      = "9000"
    })

    depends_on = [
        hcloud_server.tenant_server
    ]
}

# resource "null_resource" ""