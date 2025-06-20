# Helm Base Module

## Overview

The `stacks/helm/base` module provides a reusable and standardized way to deploy any Helm chart to a Kubernetes cluster using Terraform. It is the foundation for all Helm-based deployments in this repository, including Vault, ingress-nginx, and others.

---

## 1. Features

- **Generic Helm Release**:  
  Deploys any Helm chart by specifying chart details and configuration variables.
- **Namespace Management**:  
  Can create the target namespace automatically if it does not exist.
- **Robust Deployment Options**:  
  Supports atomic upgrades, cleanup on failure, forced updates, pod recreation, CRD skipping, and more.
- **Custom Values and Metadata**:  
  Allows passing custom values and metadata (annotations/labels) to the Helm release.
- **History and Rollback**:  
  Maintains a limited history of releases for easy rollback.

---

## 2. Key Inputs

- `helm_chart`: Name of the Helm chart to deploy.
- `helm_version`: Chart version.
- `helm_repository`: Chart repository URL.
- `helm_namespace`: Kubernetes namespace for deployment.
- `helm_create_namespace`: Whether to create the namespace if it does not exist.
- `helm_atomic`, `helm_cleanup_on_fail`, `helm_force_update`, `helm_recreate_pods`, `helm_skip_crds`, `helm_timeout`: Various deployment options.
- `helm_override`: If true, overrides default values with `helm_values`.
- `helm_values`: Custom values for the Helm chart.
- `helm_metadata`: Key-value pairs for global annotations or labels.

---

## 3. Example Usage

This module is not used directly, but is included by higher-level modules (such as Vault or ingress-nginx) like this:
```hcl
module "vault" {
  source                = "../../base"
  helm_chart            = "vault"
  helm_version          = "0.27.0"
  helm_repository       = "https://helm.releases.hashicorp.com"
  helm_namespace        = "vault-core"
  helm_create_namespace = true
  helm_atomic           = true
  helm_cleanup_on_fail  = true
  helm_override         = true
  helm_values           = local.vault_values_yaml
  helm_metadata = {
    "globalAnnotations.product" = "vault"
    # ...other metadata
  }
}
```

---

## 4. How It Works

The module creates a `helm_release` resource with all the provided options and values. Metadata is dynamically set as Helm values for annotations or labels.

---

## 5. When to Use

Use this module as the base for any new Helm chart deployment in your infrastructure. It ensures consistency, reliability, and easy customization for all Helm-based workloads.

---

For more details, see the Terraform file in `stacks/helm/base/main.tf`.