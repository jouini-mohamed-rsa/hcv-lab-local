output "lab_ca_cert_pem" {
  description = "Public certificate for the CA, to trust Vault"
  value = tls_self_signed_cert.lab_ca_cert.cert_pem
}

# If you promote this setup to real production, better replace this pattern with:
# a step-ca or Vault PKI to sign dynamically
# or use cert-manager with a real CA (like your own Root/Intermediate)

output "lab_ca_private_key_pem" {
  description = "Private key for the CA, to trust Vault"  
  value     = tls_private_key.lab_ca_key.private_key_pem
  sensitive = true
}

output "unseal_key_id" {
  value = aws_kms_key.unseal.arn
}