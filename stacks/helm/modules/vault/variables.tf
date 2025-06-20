variable "is_vault_aws_kms_enabled" {
  default     = false
  type        = bool
}

variable "is_vault_tls_enabled" {
  default     = false
  type        = bool
}

variable "is_vault_enterprise" {
  default = false
  type        = bool
}

variable "kubernetes_config_path" {
  default = "~/.kube/config"
  type    = string
}

variable "helm_atomic" {
  description = "Enable atomic mode for Helm releases"
  default     = true
  type        = bool
}

variable "helm_create_namespace" {
  description = "Create the Kubernetes namespace for the Helm release"
  default     = true
  type        = bool
}

variable "helm_namespace" {
  description = "The Kubernetes namespace in which to install the Helm release"
  default     = "vault"
  type        = string
}

variable "helm_cleanup_on_fail" {
  description = "Cleanup Helm release on failure"
  default     = true
  type        = bool
}
variable "helm_force_update" {
  description = "Force update of the Helm release"
  default     = false
  type        = bool
}
variable "helm_override" {
  description = "Override helm deployment using overrides.yaml"
  default     = false
  type        = bool
}

variable "helm_recreate_pods" {
  description = "Recreate pods on Helm release upgrade"
  default     = false
  type        = bool
}

variable "helm_skip_crds" {
  description = "Skip CRD installation during Helm release"
  default     = false
  type        = bool
}

variable "helm_timeout" {
  description = "Timeout for Helm release operations"
  default     = 300
  type        = number
}

variable "helm_values_file" {
  description = "Path to the Helm values YAML file"
  type        = string
  default     = ""
}

variable "vault_aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vault_kms_key_id" {
  description = "AWS KMS used to unseal vault"
  type        = string
  default     = ""
}

variable "is_vault_affinity_enabled" {
  description = "Enable affinity rules for Vault pods"
  default     = false
  type        = bool
}
variable "is_vault_ingress_enabled" {
  default = false
  type    = bool
}

variable "is_vault_ui_enabled" {
  default = false
  type    = bool
}

variable "vault_license_secret_name" {
  description = "Vault license secret name"
  default = "vault-ent-license"
  type    = string
}

variable "vault_host" {
  description = "Vault ingress host"
  default = "vault.localhost"
  type    = string
}

variable "vault_version" {
  description = "Vault version"
  default = "1.19"
  type    = string
}

variable "vault_replicas" {
  description = "Vault Pod replicas"
  default = "3"
  type    = string
}

variable "vault_tls_secret_name" {
  description = "Vault tls secret name"
  default = "vault-tls"
  type    = string
}

variable "aws_tags" {
  description = "AWS resource tags"
  default     = {}
  type        = map(string)
}