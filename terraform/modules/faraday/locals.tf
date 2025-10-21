locals {
  faraday_user      = "faraday"
  faraday_password  = random_password.faraday_password.result
  templates_dir     = "${path.module}/templates"
  render_dir        = "${path.module}/_rendered"
  faraday_dir       = "/tmp/faraday"
}