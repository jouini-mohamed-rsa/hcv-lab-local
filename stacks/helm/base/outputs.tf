output "helm_release_name" {
  value = helm_release.this.name
}

output "kubernetes_namespace" {
  value = helm_release.this.namespace
}