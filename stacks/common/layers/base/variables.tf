variable "is_kms_unseal_enabled" {
  description = "Whether KMS unseal is enabled"
  default     = false
  type        = bool
}

variable "kms_unseal_key_alias" {
  description = "The KMS key alias used for unsealing Vault"
  default     = "alias/vault-unseal"
  type        = string
}

variable "kubernetes_config_path" {
  description = "The path to the Kubernetes config file"
  default     = "~/.kube/config"
  type        = string
}

variable "server_ca_secret_namespace" {
  description = "The Kubernetes namespace for the server CA secret"
  default     = "kube-services"
  type        = string
}

variable "server_ca_cert_dir" {
  description = "The directory for storing the server CA certificate"
  default     = "/Users/mohamed.jouini/training/vault/certifications/ca"
  type        = string
}
