locals {
  rke2_version = "v1.28.2+rke2r1"
}

resource "local_file" "kubeconfig_yaml" {
  filename = format("%s/%s_%s", path.root, var.name_prefix, "kubeconfig.yaml")
  content  = ssh_resource.retrieve_kubeconfig.result
}
