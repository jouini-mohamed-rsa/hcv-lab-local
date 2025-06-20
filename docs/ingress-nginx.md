# Ingress-NGINX Controller Deployment

## Overview

This document describes how the `ingress-nginx` layer deploys the NGINX Ingress Controller using a Helm chart in the Kubernetes cluster.

---

## 1. Helm Chart Deployment

The deployment uses a Terraform module to manage the Helm release for the NGINX Ingress Controller.

- **Helm Chart**:  
  The official `ingress-nginx` Helm chart is used.
- **Repository**:  
  The chart is sourced from `https://kubernetes.github.io/ingress-nginx`.
- **Version**:  
  The deployed version is `4.10.0`.
- **Namespace**:  
  The controller is installed in the `ingress-nginx` namespace, which is created if it does not exist.

**Key Helm options:**
- `helm_atomic`: Ensures atomic upgrades/installs.
- `helm_cleanup_on_fail`: Cleans up resources on failure.
- `helm_timeout`: Sets the operation timeout (300 seconds).
- `helm_metadata`: Adds global annotations for product, platform, architecture, and repository.

---

## 2. Customization

You can override or extend the Helm values and options by passing additional variables to the module as needed.

---

## Example

The deployment is defined in Terraform as:
```hcl
module "vault" {
  source                = "../../base"
  helm_chart            = "ingress-nginx"
  helm_version          = "4.10.0"
  helm_repository       = "https://kubernetes.github.io/ingress-nginx"
  helm_namespace        = "ingress-nginx"
  helm_create_namespace = true
  helm_atomic           = true
  helm_cleanup_on_fail  = true
  helm_timeout          = 300
  helm_metadata = {
    "globalAnnotations.product"    = "ingress-nginx"
    "globalAnnotations.platform"   = "docker Desktop"
    "globalAnnotations.arch"       = "arm64"
    "globalAnnotations.repository" = "remote"
  }
  # Add other variables as needed
}
```

---

## 3. Usage

To deploy the NGINX Ingress Controller, run:
```sh
task deploy STACK=helm LAYER=ingress-nginx
```

---

For more details, see the Terraform file in `stacks/helm/layers/ingress-nginx/main.tf`.