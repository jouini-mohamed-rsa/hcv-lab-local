module "vault" {
  source = "../../base"

  helm_chart            = "ingress-nginx"
  helm_version          = "4.10.0"
  helm_repository       = "https://kubernetes.github.io/ingress-nginx"
  helm_namespace        = "ingress-nginx"
  helm_create_namespace = true

  helm_atomic          = true
  helm_cleanup_on_fail = true
  helm_force_update    = false
  helm_override        = true
  helm_recreate_pods   = false
  helm_skip_crds       = false
  helm_timeout         = 600

  helm_metadata = {
    "globalAnnotations.product"         = "ingress-nginx"
    "globalAnnotations.platform"        = "docker Desktop"
    "globalAnnotations.arch"            = "arm64"
    "globalAnnotations.repository"      = "remote"
  }
  # pass other variables here as needed
  helm_values                           = file("./dotenv/values.yaml")
}