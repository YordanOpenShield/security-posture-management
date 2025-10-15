data "hcloud_server_types" "all" {}

data "hcloud_server_type" "selected" {
  for_each = {
    for st in data.hcloud_server_types.all.server_types : st.name => st if st.cores >= var.server_cpu && st.memory >= var.server_ram && st.architecture == "x86"
  }
  name = each.key
}