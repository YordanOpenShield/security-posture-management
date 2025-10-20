locals {
  chosen_server_type = values(data.hcloud_server_type.selected)[0].name

  faraday_user     = "faraday"
}
