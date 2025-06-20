resource "null_resource" "restart_deployment" {
  triggers = {
    configmap_sha = sha256(file("~/.aws/credentials"))
  }

  provisioner "local-exec" {
    command = format("kubectl rollout restart statefulset vault -n %s", var.helm_namespace)
    interpreter = ["/bin/bash", "-c"]
  }
}