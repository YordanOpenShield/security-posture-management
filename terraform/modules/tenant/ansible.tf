resource "ansible_group" "tenant_hosts" {
  name = "${var.name}-group"
}

resource "ansible_host" "tenant_host" {
  name = hcloud_server.tenant_server.ipv4_address
  groups = [ansible_group.tenant_hosts.name]
}

resource "ansible_playbook" "tenant_configure" {
  playbook = "../ansible/playbooks/tenant.yml"
  name = ansible_host.tenant_host.name
  replayable = true

  verbosity = 6

  extra_vars = {
    tenant_name = var.name
    pg_user     = local.postgres_user
    pg_password = random_password.pg_password.result
  }

  depends_on = [hcloud_server.tenant_server, hcloud_ssh_key.ssh_key]
}
