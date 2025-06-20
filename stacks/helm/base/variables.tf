variable "team_region" {
  description = "Team region"
  default     = "EMEA"
  type        = string
}

variable "team_name" {
  description = "Team name"
  default     = "RTS/RSA"
  type        = string
}

variable "helm_atomic" {
  description = "If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used"
  default     = true
  type        = bool
}

variable "helm_cleanup_on_fail" {
  description = "Allow deletion of new resources created in this upgrade when upgrade fails."
  default     = true
  type        = bool
}

variable "helm_chart" {
  description = "Chart name (for remote) or relative path (for local) to the Helm chart"
  default = null
  type    = string
}

variable "helm_chart_name" {
  description = "Optional release name. If not set, it is derived from chart path/name."
  default     = null
  type        = string
}
variable "helm_create_namespace" {
  description = "Whether to create the namespace if it doesn't exist"
  default     = true
  type        = bool
}

variable "helm_force_update" {
  description = "Force resource update through delete/recreate if needed"
  default     = true
  type        = bool
}

variable "kubernetes_config_path" {
  default = "~/.kube/config"
  type    = string
}

variable "helm_metadata" {
  description = "Global annotations to apply to Helm chart resources that support it."
  default = {}
  type        = map(string)
}

variable "helm_namespace" {
  description = "The Kubernetes namespace in which to install the Helm release"
  default     = "hashicorp"
  type        = string
}

variable "helm_override" {
  description = "Override helm deployment using overrides.yaml"
  default     = false
  type        = bool
}

variable "helm_recreate_pods" {
  description = "Perform pods restart during upgrade/rollback"
  default     = false
  type        = bool
}

variable "helm_repository" {
  description = "The Helm repository URL (set only if using a remote chart)"
  default     = "null"
  type        = string
}

variable "helm_skip_crds" {
  description = "If set, no CRDs will be installed. By default, CRDs are installed if not already present."
  default     = false
  type        = bool
}

variable "helm_timeout" {
  description = "Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks)."
  default     = 300
  type        = number
}

variable "helm_values" {
  description = "Helm values content"
  default     = null
  type        = string
}

variable "helm_version" {
  description = "Version of the Helm chart to install"
  default     = null
  type        = string
}