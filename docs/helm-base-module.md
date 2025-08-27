# Helm Base Module Documentation

## Overview

The `stacks/helm/base` module is a reusable Terraform module that provides a standardized way to deploy any Helm chart to a Kubernetes cluster. It serves as the foundation for all Helm-based deployments in this repository, ensuring consistency, reliability, and best practices across different applications.

---

## Purpose

This module abstracts the complexity of Helm deployments by:
- Providing a consistent interface for deploying any Helm chart
- Implementing best practices for Helm release management
- Supporting both local and remote charts
- Enabling standardized metadata and annotations
- Managing namespace creation and release lifecycle

---

## Features

### Core Functionality
- **Universal Helm Deployment**: Deploy any Helm chart (local or remote)
- **Atomic Operations**: Ensures rollback on failure
- **Namespace Management**: Automatic namespace creation if needed
- **Release History**: Maintains limited history for rollbacks
- **Robust Error Handling**: Cleanup on failure and force updates
- **Metadata Injection**: Automatic team and custom annotations

### Advanced Features
- **Custom Values Override**: Support for custom values files
- **Dynamic Chart Naming**: Intelligent chart name resolution
- **CRD Management**: Optional CRD installation control
- **Pod Recreation**: Controlled pod restart during upgrades
- **Timeout Configuration**: Configurable operation timeouts

---

## Module Structure

```
stacks/helm/base/
├── main.tf          # Helm release resource definition
├── variables.tf     # Input variable definitions
├── locals.tf        # Local value computations
└── outputs.tf       # Output values
```

---

## Variables

### Required Variables
| Variable | Type | Description |
|----------|------|-------------|
| `helm_chart` | string | Chart name (remote) or path (local) |

### Optional Variables
| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `helm_version` | string | `null` | Chart version to install |
| `helm_repository` | string | `"null"` | Repository URL for remote charts |
| `helm_namespace` | string | `"hashicorp"` | Target Kubernetes namespace |
| `helm_chart_name` | string | `null` | Custom release name |
| `helm_create_namespace` | bool | `true` | Create namespace if it doesn't exist |
| `helm_atomic` | bool | `true` | Enable atomic operations |
| `helm_cleanup_on_fail` | bool | `true` | Cleanup resources on failure |
| `helm_force_update` | bool | `true` | Force resource updates |
| `helm_recreate_pods` | bool | `false` | Recreate pods during upgrade |
| `helm_skip_crds` | bool | `false` | Skip CRD installation |
| `helm_timeout` | number | `300` | Operation timeout in seconds |
| `helm_override` | bool | `false` | Use custom values |
| `helm_values` | string | `null` | Custom values content |
| `helm_metadata` | map(string) | `{}` | Custom annotations |
| `team_region` | string | `"EMEA"` | Team region for annotations |
| `team_name` | string | `"RTS/RSA"` | Team name for annotations |
| `kubernetes_config_path` | string | `"~/.kube/config"` | Kubernetes config path |

---

## Outputs

| Output | Description |
|--------|-------------|
| `helm_release_name` | Name of the created Helm release |
| `kubernetes_namespace` | Namespace where the release is deployed |

---

## Usage Examples

### Example 1: NGINX Ingress Controller

```hcl
module "ingress_nginx" {
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
  helm_timeout         = 600

  helm_metadata = {
    "product"    = "ingress-nginx"
    "platform"   = "docker Desktop"
    "arch"       = "arm64"
    "repository" = "remote"
  }
  
  helm_values = file("./dotenv/values.yaml")
}
```

### Example 2: HashiCorp Vault

```hcl
module "vault" {
  source = "../../base"

  helm_chart            = "vault"
  helm_version          = "0.27.0"
  helm_repository       = "https://helm.releases.hashicorp.com"
  helm_namespace        = var.helm_namespace
  helm_create_namespace = var.helm_create_namespace

  helm_atomic          = var.helm_atomic
  helm_cleanup_on_fail = var.helm_cleanup_on_fail
  helm_force_update    = var.helm_force_update
  helm_override        = var.helm_override
  helm_recreate_pods   = var.helm_recreate_pods
  helm_skip_crds       = var.helm_skip_crds
  helm_timeout         = var.helm_timeout

  helm_metadata = {
    "product"    = "vault"
    "platform"   = "docker Desktop"
    "arch"       = "arm64"
    "repository" = "remote"
  }
  
  helm_values = local.vault_values_yaml
}
```

### Example 3: Local Chart Deployment

```hcl
module "local_chart" {
  source = "../../base"

  helm_chart            = "./path/to/local/chart"
  helm_chart_name       = "my-custom-app"
  helm_namespace        = "my-namespace"
  helm_create_namespace = true

  helm_metadata = {
    "environment" = "dev"
    "component"   = "web-app"
  }
}
```

---

## How It Works

### Chart Name Resolution
The module intelligently determines the release name:
1. If `helm_repository` is set: uses `helm_chart` as the name
2. If `helm_chart_name` is provided: uses that as the name
3. Otherwise: extracts the last segment from the chart path

### Metadata Injection
The module automatically adds team annotations:
- `globalAnnotations.team_region`: Team region
- `globalAnnotations.team_name`: Team name
- Plus any custom annotations from `helm_metadata`

### Values Override
When `helm_override` is `true`, the module uses the provided `helm_values` content to override default chart values.

---

## Best Practices

### 1. Use Specific Versions
Always specify `helm_version` for production deployments:
```hcl
helm_version = "1.2.3"
```

### 2. Enable Atomic Operations
Keep `helm_atomic = true` for safe deployments:
```hcl
helm_atomic = true
```

### 3. Set Appropriate Timeouts
Adjust timeout based on deployment complexity:
```hcl
helm_timeout = 600  # 10 minutes for complex deployments
```

### 4. Use Custom Values Files
For complex configurations, use external values files:
```hcl
helm_override = true
helm_values   = file("./values.yaml")
```

### 5. Tag Resources Properly
Use metadata for resource tracking:
```hcl
helm_metadata = {
  "environment" = "production"
  "component"   = "api-gateway"
  "owner"       = "platform-team"
}
```

---

## Integration with Task Runner

Deploy using the task runner:
```bash
# Deploy a specific layer
task deploy STACK=helm LAYER=ingress-nginx

# Deploy Vault core
task deploy STACK=helm LAYER=vault-core
```

---

## Troubleshooting

### Common Issues

1. **Namespace Already Exists**: Set `helm_create_namespace = false`
2. **Timeout Errors**: Increase `helm_timeout` value
3. **CRD Conflicts**: Set `helm_skip_crds = true` if CRDs exist
4. **Failed Upgrades**: Enable `helm_cleanup_on_fail = true`

### Debugging

Check Helm release status:
```bash
helm list -n <namespace>
helm status <release-name> -n <namespace>
```

---

## Dependencies

- **Terraform**: >= 0.14
- **Helm Provider**: >= 2.0
- **Kubernetes Cluster**: Accessible via kubectl
- **Helm Charts**: Available in specified repositories

---

## Security Considerations

- Ensure proper RBAC permissions for Helm operations
- Use secure repositories for chart downloads
- Validate custom values files for sensitive data
- Consider using sealed secrets for sensitive configurations

---

For more examples and advanced usage, see the implementations in:
- `stacks/helm/layers/ingress-nginx/`
- `stacks/helm/layers/vault-core/`
- `stacks/helm/modules/vault/`