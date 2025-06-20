# Certificate Authority (CA) and AWS KMS Integration for Vault

## Overview

This document describes how the base layer provisions a Certificate Authority (CA) for Vault TLS and an AWS KMS key for Vault unsealing, depending on the configuration flags.

---

## 1. Certificate Authority (CA) for Vault TLS

When the variable `is_vault_tls_enabled` is set to `true`, a self-signed CA is created to sign Vault's TLS certificates.

- **CA Generation**:  
  The CA is generated using the `tls_private_key` and `tls_self_signed_cert` Terraform resources.
- **Namespace**:  
  The CA certificate and key are stored as a Kubernetes secret (`lab-ca-tls`) in the `kube-services` namespace.
- **Usage**:  
  This CA is used to sign the TLS certificates for Vault, enabling secure communication.

**Relevant Terraform resources:**
- `tls_private_key.lab_ca_key`
- `tls_self_signed_cert.lab_ca_cert`
- `kubernetes_secret.lab_ca_tls`

---

## 2. AWS KMS Key for Vault Unsealing

When the variable `is_vault_aws_kms_enabled` is set to `true`, an AWS KMS key is provisioned for Vault's auto-unseal feature.

- **KMS Key Creation**:  
  The KMS key is created using the `aws_kms_key` resource with key rotation enabled.
- **Alias**:  
  An alias `alias/vault-unseal` is created for easy reference.
- **Usage**:  
  Vault uses this KMS key to securely unseal itself without manual intervention.

**Relevant Terraform resources:**
- `aws_kms_key.unseal`
- `aws_kms_alias.unseal`

---

## 3. Configuration Variables

- `is_vault_tls_enabled` (bool): Enable/disable Vault TLS and CA creation.
- `is_vault_aws_kms_enabled` (bool): Enable/disable AWS KMS key for Vault unsealing.

---

## Example

To enable both features, set the following variables:
```hcl
is_vault_tls_enabled      = true
is_vault_aws_kms_enabled = true
```

For more details, see the Terraform files in `stacks/common/layers/base/`.