variable "is_vault_tls_enabled" {
  default = false
}

variable "is_vault_entreprise" {
  default = false
}

variable "kubernetes_config_path" {
  default = "~/.kube/config"
  type    = string
}