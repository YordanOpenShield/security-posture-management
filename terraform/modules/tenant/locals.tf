locals {
  chosen_server_type = values(data.hcloud_server_type.selected)[keys(data.hcloud_server_type.selected)[0]].name
}
