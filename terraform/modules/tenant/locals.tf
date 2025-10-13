locals {
  chosen_server_type = values(data.hcloud_server_type.selected)[data.hcloud_server_type.selected.name].name
}
