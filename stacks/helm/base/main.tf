resource "helm_release" "this" {
  name             = local.helm_chart_name

  atomic           = var.helm_atomic
  chart            = var.helm_chart
  create_namespace = var.helm_create_namespace
  cleanup_on_fail  = var.helm_cleanup_on_fail
  force_update     = var.helm_force_update
  lint             = true
  namespace        = var.helm_namespace
  max_history      = 2
  repository       = var.helm_repository
  recreate_pods    = var.helm_recreate_pods
  skip_crds        = var.helm_skip_crds
  timeout          = var.helm_timeout
  version          = var.helm_version
  values           = var.helm_override ? [var.helm_values] : []

  
  dynamic "set" {
    for_each = local.helm_metadata

    content {
      name  = set.key
      value = set.value
    }
  }
}
