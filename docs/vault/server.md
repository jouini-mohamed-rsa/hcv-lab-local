# Vault-Core Deployment

## Overview

This document describes how the `vault-core` layer deploys HashiCorp Vault in the Kubernetes cluster using a Helm chart, with configuration and logic provided by the `modules/vault` module.

---

## 1. Helm Chart Deployment

The deployment uses a Terraform module to manage the Helm release for HashiCorp Vault.

- **Helm Chart**:  
  The official `vault` Helm chart from HashiCorp is used.
- **Repository**:  
  The chart is sourced from `https://helm.releases.hashicorp.com`.
- **Version**:  
  The deployed version is `0.27.0`.
- **Namespace**:  
  Vault is installed in the `vault-core` namespace, which is created if it does not exist.

**Key Helm options:**
- `helm_atomic`, `helm_cleanup_on_fail`, `helm_override`, etc., are configurable for robust deployments.
- `helm_metadata`: Adds global annotations for product, platform, architecture, and repository.
- `helm_values`: Custom values for the Vault Helm chart are provided via `local.vault_values_yaml`.

---

## 2. Vault Features and Configuration

The `vault-core` layer is highly configurable via module inputs:

- **TLS**:  
  TLS is enabled (`is_vault_tls_enabled = true`), and Vault certificates are signed by the internal CA.
- **AWS KMS Unseal**:  
  AWS KMS is enabled (`is_vault_aws_kms_enabled = true`) for auto-unsealing Vault.
- **Enterprise Features**:  
  Vault Enterprise is enabled (`is_vault_enterprise = true`).
- **Ingress**:  
  Ingress is enabled for external access (`is_vault_ingress_enabled = true`).
- **UI**:  
  The Vault UI is enabled (`is_vault_ui_enabled = true`).
- **Replicas**:  
  Vault is deployed with 3 replicas for high availability.
- **AWS Tags**:  
  Custom tags are set for AWS resources.

---

## 3. Module Structure

- `stacks/helm/layers/vault-core/main.tf`:  
  Configures the `vault-core` deployment and passes variables to the module.
- `stacks/helm/modules/vault/main.tf`:  
  Implements the Helm release logic for Vault, referencing the base module for shared Helm logic.

---

## Example

The deployment is defined in Terraform as:
```hcl
module "vault-core" {
  source = "../../modules/vault"
  is_vault_affinity_enabled = false
  is_vault_aws_kms_enabled  = true
  is_vault_enterprise       = true
  is_vault_ingress_enabled  = true
  is_vault_tls_enabled      = true
  is_vault_ui_enabled       = true
  helm_namespace            = "vault-core"
  helm_override             = true
  vault_aws_region          = "us-east-1"
  vault_host                = "vault.localhost"
  vault_kms_key_id          = ""
  vault_version             = "1.19"
  vault_replicas            = "3"
  aws_tags = {
    env                = "dev"
    region             = "us-east-1"
    owner              = "mahamed"
    lab_name           = "vault-lab"
    vault_cluster_name = "vault-core"
  }
}
```

---

## 4. Usage

To deploy Vault, run:
```sh
task deploy STACK=helm LAYER=vault-core
```

---

For more details, see the Terraform files in `stacks/helm/layers/vault-core/` and `stacks/helm/modules/vault/`.