# Ingress-NGINX Layer Documentation

## Overview

The `ingress-nginx` layer deploys the NGINX Ingress Controller to provide external access to services running in the Kubernetes cluster. This layer is specifically configured for Docker Desktop Kubernetes environments and includes SSL passthrough capabilities essential for Vault's mTLS communication.

## Purpose

This layer serves as the entry point for external traffic into the Kubernetes cluster, enabling:
- HTTP/HTTPS traffic routing to internal services
- SSL/TLS termination and passthrough
- Load balancing across multiple service replicas
- Support for Vault's mutual TLS (mTLS) authentication

## Architecture

### Components
- **NGINX Ingress Controller**: Manages ingress resources and routes traffic
- **LoadBalancer Service**: Exposes the controller (Docker Desktop provides this)
- **SSL Passthrough**: Allows encrypted traffic to flow directly to backend services

### Configuration Files
```
stacks/helm/layers/ingress-nginx/
├── main.tf              # Terraform module configuration
└── dotenv/
    └── values.yaml      # Helm chart custom values
```

## Configuration Details

### Terraform Configuration (`main.tf`)

```hcl
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

### Helm Values Configuration (`dotenv/values.yaml`)

```yaml
controller:
  extraArgs:
    enable-ssl-passthrough: "true"
  replicaCount: 1
```

## Key Features

### SSL Passthrough Configuration

The `enable-ssl-passthrough: "true"` setting is crucial for Vault's mTLS functionality:

#### What it does:
- **Bypasses SSL termination** at the ingress level
- **Passes encrypted traffic directly** to the backend service (Vault)
- **Preserves original SSL certificates** from client to server
- **Enables end-to-end encryption** without ingress interference

#### Why it's needed for Vault mTLS:
```
Without SSL Passthrough:
Client → [TLS] → Ingress → [Decrypt] → [Re-encrypt] → Vault
                          ❌ Ingress certificate used, not Vault's

With SSL Passthrough:
Client → [TLS] → Ingress → [Pass-through] → Vault
                          ✅ Vault's certificate preserved
```

#### mTLS Use Case:
- **Client certificates** are validated directly by Vault
- **Server certificates** from Vault CA are preserved
- **Certificate chain integrity** maintained end-to-end
- **No certificate substitution** by the ingress controller

### Docker Desktop Optimization

The configuration is optimized for Docker Desktop environments:
- **Single replica**: Suitable for development/lab environments
- **ARM64 architecture**: Compatible with Apple Silicon Macs
- **LoadBalancer service**: Leverages Docker Desktop's built-in load balancer

## Deployment

### Using Task Runner
```bash
# Deploy ingress-nginx
task deploy STACK=helm LAYER=ingress-nginx

# Verify deployment
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

### Manual Deployment
```bash
cd stacks/helm/layers/ingress-nginx
terraform init
terraform plan
terraform apply
```

## Verification

### Check Controller Status
```bash
# Verify pods are running
kubectl get pods -n ingress-nginx

# Check service exposure
kubectl get svc -n ingress-nginx

# Verify ingress class
kubectl get ingressclass
```

### Test SSL Passthrough
```bash
# Check if SSL passthrough is enabled
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller | grep "ssl-passthrough"
```

### Expected Output
```bash
$ kubectl get svc -n ingress-nginx
NAME                                 TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)
ingress-nginx-controller             LoadBalancer   10.96.x.x      localhost     80:xxxxx/TCP,443:xxxxx/TCP
```

## Integration with Vault

### Ingress Resource Example
When Vault is deployed, it will create an ingress resource like:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: vault-ingress
  annotations:
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  ingressClassName: nginx
  rules:
  - host: vault.localhost
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: vault
            port:
              number: 8200
```

### mTLS Flow
```
1. Client connects to https://vault.localhost
2. Docker Desktop routes to ingress-nginx (port 443)
3. Ingress-nginx passes SSL traffic directly to Vault pod
4. Vault receives original client certificate for validation
5. Vault responds with its own certificate (signed by lab CA)
6. End-to-end mTLS established without ingress interference
```

## Troubleshooting

### Common Issues

**1. Ingress not accessible**
```bash
# Check if LoadBalancer has external IP
kubectl get svc -n ingress-nginx ingress-nginx-controller

# On Docker Desktop, external IP should be 'localhost'
```

**2. SSL passthrough not working**
```bash
# Verify SSL passthrough is enabled
kubectl describe configmap -n ingress-nginx ingress-nginx-controller

# Should contain: enable-ssl-passthrough: "true"
```

**3. Certificate issues with Vault**
```bash
# Check if ingress is terminating SSL (should not with passthrough)
curl -k -v https://vault.localhost

# Look for certificate issuer - should be your lab CA, not ingress
```

### Debug Commands
```bash
# Check ingress controller logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# Verify configuration
kubectl get configmap -n ingress-nginx ingress-nginx-controller -o yaml

# Test connectivity
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
```

## Security Considerations

### SSL Passthrough Security
- **Benefits**: End-to-end encryption, certificate validation at application level
- **Considerations**: Ingress cannot inspect or modify encrypted traffic
- **Best Practice**: Use with applications that handle their own SSL/TLS (like Vault)

### Docker Desktop Environment
- **Local only**: Not suitable for production internet exposure
- **Development focused**: Perfect for lab and testing environments
- **Simplified networking**: Docker Desktop handles external access

## Customization

### Production Adjustments
For production environments, consider:

```yaml
controller:
  extraArgs:
    enable-ssl-passthrough: "true"
  replicaCount: 3                    # High availability
  resources:                         # Resource limits
    requests:
      memory: "256Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  nodeSelector:                      # Node placement
    kubernetes.io/os: linux
```

### Additional Features
```yaml
controller:
  extraArgs:
    enable-ssl-passthrough: "true"
    default-ssl-certificate: "ingress-nginx/default-ssl-cert"
  config:
    proxy-buffer-size: "16k"         # For large headers
    proxy-read-timeout: "300"        # Extended timeouts
```

## Dependencies

- **Kubernetes cluster**: Docker Desktop or compatible
- **Helm**: For chart deployment
- **DNS resolution**: For `*.localhost` domains (automatic in Docker Desktop)

## Next Steps

After deploying ingress-nginx:
1. Deploy Vault core layer
2. Verify Vault ingress with SSL passthrough
3. Test mTLS connectivity to Vault
4. Configure client certificates for Vault access

---

For more information about NGINX Ingress Controller, visit the [official documentation](https://kubernetes.github.io/ingress-nginx/).