locals {
  chosen_server_type = values(data.hcloud_server_type.selected)[0].name

  ansible_user  = "deploy"

  postgres_user = "faraday"
  rabbitmq_user = "faraday"
}
