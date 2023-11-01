resource "tls_private_key" "ssh_key" {
  algorithm = "ED25519"
}

resource "local_sensitive_file" "ssh_private_key_openssh" {
  filename        = "${path.module}/${var.name_prefix}_ed25519"
  content         = tls_private_key.ssh_key.private_key_openssh
  file_permission = "0600"
}

resource "local_file" "ssh_public_key_openssh" {
  filename = "${path.module}/${var.name_prefix}_ed25519.pub"
  content  = tls_private_key.ssh_key.public_key_openssh
}
