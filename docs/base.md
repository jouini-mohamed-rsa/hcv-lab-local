# Common Base Layer Documentation

## Overview

The `common/layers/base` layer is the foundational infrastructure component that provisions essential resources for the Vault lab environment. It creates the core security infrastructure including a Certificate Authority (CA) for TLS certificates and AWS KMS keys for Vault unsealing.

---

## Components

### 1. Server Certificate Authority (CA)

The layer creates a self-signed Certificate Authority that serves as the root trust anchor for all TLS certificates in the environment.

#### Resources Created:
- **TLS Private Key**: 4096-bit RSA key for the CA
- **Self-Signed CA Certificate**: Root CA certificate with 1-year validity
- **Kubernetes Secret**: Stores the CA certificate and private key as a TLS secret
- **Local Files**: Saves CA certificate and key to local filesystem for client use

#### Configuration:
- **Subject**: Common Name: "Server Root CA", Organization: "HashiCorp", OU: "RTS"
- **Validity**: 8760 hours (1 year) with early renewal at 720 hours
- **Key Usage**: Certificate signing and CRL signing
- **Storage**: Kubernetes secret `server-ca-tls` in configurable namespace (default: `kube-services`)

### 2. AWS KMS for Vault Unsealing

When enabled, creates an AWS KMS key for Vault's auto-unseal functionality.

#### Resources Created:
- **KMS Key**: Encryption key with automatic rotation enabled
- **KMS Alias**: Human-readable alias for the key (default: `alias/vault-unseal`)

#### Configuration:
- **Deletion Window**: 10 days
- **Key Rotation**: Enabled
- **Tags**: Environment metadata for resource management

---

## Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `is_kms_unseal_enabled` | bool | `false` | Enable/disable KMS key creation for Vault unsealing |
| `kms_unseal_key_alias` | string | `"alias/vault-unseal"` | Alias for the KMS key |
| `kubernetes_config_path` | string | `"~/.kube/config"` | Path to Kubernetes configuration file |
| `server_ca_secret_namespace` | string | `"kube-services"` | Kubernetes namespace for CA secret |
| `server_ca_cert_dir` | string | `"~/certifications/ca"` | Local directory for CA certificate files |

**Note**: All variables can be customized by updating the `layer.tfvars` file in this directory.

---

## Configuration

### Customizing Variables

The layer uses a `layer.tfvars` file to override default variable values. You can modify this file to customize the deployment according to your environment:

```hcl
# KMS Unseal Configuration
is_kms_unseal_enabled = true
kms_unseal_key_alias  = "alias/vault-unseal"

# Kubernetes Configuration
kubernetes_config_path = "~/.kube/config"

# Server CA Configuration
server_ca_cert_dir = "/Users/mohamed.jouini/certifications/ca"
server_ca_secret_namespace = "kube-services"
```

**Important**: Update the `server_ca_cert_dir` path to match your local environment where you want the CA certificates to be stored.

---

## Outputs

| Output | Description | Sensitive |
|--------|-------------|-----------|
| `server_ca_cert_pem` | Public certificate for the Server CA | No |
| `server_ca_private_key_pem` | Private key for the Server CA | Yes |
| `unseal_key_id` | ARN of the KMS key for unsealing | No |

---

## Usage

### Deploy the Base Layer

```bash
task deploy STACK=common LAYER=base
```

The deployment automatically uses the values from `layer.tfvars` to configure the resources.

### Modifying Configuration

1. Edit the `layer.tfvars` file to update variable values
2. Redeploy using the task command above
3. Terraform will apply the changes based on the updated configuration

---

## Security Considerations

### Certificate Authority
- The CA is self-signed and suitable for lab/development environments
- For production, consider using:
  - External CA providers
  - step-ca for automated certificate management
  - cert-manager with proper CA integration

### KMS Key
- Key rotation is automatically enabled
- Deletion protection with 10-day window
- Proper IAM permissions required for Vault to access the key

---

## File Structure

```
stacks/common/layers/base/
├── server_ca.tf          # CA certificate and key generation
├── kms.tf               # AWS KMS key for Vault unsealing
├── variables.tf         # Input variables definition
├── locals.tf           # Local values and tags
├── outputs.tf          # Output values
├── providers.tf        # Provider configurations
└── layer.tfvars        # Variable values (customize here)
```

---

## Dependencies

- **Providers**: AWS provider, Kubernetes provider, TLS provider
- **Prerequisites**: 
  - AWS credentials configured
  - Kubernetes cluster accessible
  - kubectl configured with appropriate permissions

---

## Next Steps

After deploying the base layer:
1. The CA certificate will be available in Kubernetes for other components
2. The KMS key can be referenced by Vault for auto-unsealing
3. Local CA files can be used for client certificate validation
4. Deploy the Helm layers (ingress-nginx, vault-core) that depend on these resources

---

For more information, see the individual Terraform files in the `stacks/common/layers/base/` directory.