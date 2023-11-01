output "ssh_private_key_pem" {
  value = local_sensitive_file.ssh_private_key_pem.filename
}

output "ssh_public_key_openssh" {
  value = local_file.ssh_public_key_openssh.filename
}
