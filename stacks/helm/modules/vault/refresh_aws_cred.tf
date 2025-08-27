resource "null_resource" "restart_deployment" {
  depends_on = [
    module.vault
  ]

  triggers = {
    configmap_sha = sha256(file(var.kubernetes_config_path))
  }

  provisioner "local-exec" {
    command = format("kubectl rollout restart statefulset vault -n %s", var.helm_namespace)
    # kubectl delete pod -l app.kubernetes.io/name=vault  -n vault-core
    interpreter = ["/bin/bash", "-c"]
  }
}