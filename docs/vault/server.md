# How to Deploy Vault-Core Server

## Overview

Quick deployment guide for HashiCorp Vault Enterprise server with mTLS, high availability, and AWS KMS auto-unsealing. This guide focuses on the server deployment and management.

## Prerequisites

1. **Base infrastructure deployed**:
   ```bash
   task deploy STACK=common LAYER=base
   ```

2. **NGINX Ingress deployed**:
   ```bash
   task deploy STACK=helm LAYER=ingress-nginx
   ```

3. **Required files in place**:
   - Vault Enterprise license: `/Users/mohamed.jouini/training/vault/license/vault.hclic`

4. **AWS credentials configured** for KMS operations

## Server Deployment

### 1. Deploy Vault-Core Server
```bash
# Single command deployment
task deploy STACK=helm LAYER=vault-core

# Alternative manual deployment
cd stacks/helm/layers/vault-core
terraform apply
```

### 2. Verify Server Deployment

```bash
# Check namespace
kubectl get namespace vault-core

# Check pods status
kubectl get pods -n vault-core

# Expected output:
# NAME      READY   STATUS    RESTARTS   AGE
# vault-0   0/1     Running   0          2m  (not ready until initialized)
# vault-1   0/1     Running   0          2m  
# vault-2   0/1     Running   0          2m

# Check services
kubectl get svc -n vault-core

# Check ingress
kubectl get ingress -n vault-core
```

### 3. Check Server Configuration

**Check mounted secrets:**
```bash
# Server TLS certificates
kubectl exec -n vault-core vault-0 -- ls -la /vault/userconfig/vault-tls/

# Enterprise license
kubectl exec -n vault-core vault-0 -- ls -la /vault/userconfig/vault-license/

# AWS credentials for KMS
kubectl exec -n vault-core vault-0 -- ls -la /vault/userconfig/
```

## Server Status and Health

### 1. Check Server Status
```bash
# View server logs
kubectl logs -n vault-core vault-0
kubectl logs -n vault-core vault-1  
kubectl logs -n vault-core vault-2

# Follow logs in real-time
kubectl logs -n vault-core vault-0 -f

# Check all vault pods logs
kubectl logs -n vault-core -l app.kubernetes.io/name=vault
```

### 2. Verify Server Health

**Check listener configuration:**
```bash
# Verify TLS listener is configured
kubectl logs -n vault-core vault-0 | grep -i "listener\|tls"

# Check cluster addresses
kubectl logs -n vault-core vault-0 | grep -i "cluster_address\|api_addr"
```

**Check enterprise features:**
```bash
# Verify enterprise license loaded
kubectl logs -n vault-core vault-0 | grep -i "license\|enterprise"
```

**Check KMS unsealing:**
```bash
# Verify KMS configuration
kubectl logs -n vault-core vault-0 | grep -i "kms\|unseal"
```

**Check pod readiness and liveness:**
```bash
kubectl describe pod vault-0 -n vault-core

# Check pod resource usage
kubectl top pod vault-0 -n vault-core
```

## Server Initialization

### 1. Initialize the cluster on vault-0

```bash
kubectl exec -it vault-0 -n vault-core -- vault operator init
```

Because KMS auto-unseal is configured you receive **recovery keys** (not unseal keys) and one **initial root token**. Copy them to a secure location.

### 2. Confirm vault-0 auto-unsealed

```bash
kubectl exec vault-0 -n vault-core -- vault status
```

`Sealed` must be **false** and `Seal Type` must show **awskms**.

### 3. Join vault-1 and vault-2 to the Raft cluster (correct TLS paths)

```bash
# join vault-1
kubectl exec -it vault-1 -n vault-core -- vault operator raft join \
  -leader-ca-cert="$(kubectl exec vault-1 -n vault-core -- cat /vault/userconfig/vault-tls/ca.crt)" \
  -leader-client-cert="$(kubectl exec vault-1 -n vault-core -- cat /vault/clientconfig/vault-tls/tls.crt)" \
  -leader-client-key="$(kubectl exec vault-1 -n vault-core -- cat /vault/clientconfig/vault-tls/tls.key)" \
  https://vault-0.vault-internal:8200

# join vault-2
kubectl exec -it vault-2 -n vault-core -- vault operator raft join \
  -leader-ca-cert="$(kubectl exec vault-2 -n vault-core -- cat /vault/userconfig/vault-tls/ca.crt)" \
  -leader-client-cert="$(kubectl exec vault-2 -n vault-core -- cat /vault/clientconfig/vault-tls/tls.crt)" \
  -leader-client-key="$(kubectl exec vault-2 -n vault-core -- cat /vault/clientconfig/vault-tls/tls.key)" \
  https://vault-0.vault-internal:8200
```

`vault operator raft join` requires the **leader-*** TLS flags when TLS is enabled.

> **Note**: `-leader-client-cert` and `-leader-client-key` are optional but recommended for mTLS

### 4. Auto-join Configuration (Recommended for Kubernetes)

Instead of manual joining, you can configure auto-join in the Vault configuration for Kubernetes deployments. This automatically discovers and joins cluster members:

```hcl
# In Vault configuration
storage "raft" {
  path = "/vault/data"
  
  retry_join {
    leader_api_addr = "https://vault-0.vault-internal:8200"
    leader_ca_cert_file = "/vault/userconfig/vault-tls/ca.crt"
    leader_client_cert_file = "/vault/clientconfig/vault-tls/tls.crt"
    leader_client_key_file = "/vault/clientconfig/vault-tls/tls.key"
  }
}
```

This configuration allows vault-1 and vault-2 to automatically join vault-0 when they start, making the deployment more resilient and automated.

## Raft Cluster Management

### 1. Check Raft Status
```bash
# Execute commands inside Vault pod
kubectl exec -n vault-core vault-0 -- vault status

# Check Raft peers
kubectl exec -n vault-core vault-0 -- vault operator raft list-peers

# Expected output:
# Node       Address                        State       Voter
# vault-0    vault-0.vault-internal:8201    leader      true
# vault-1    vault-1.vault-internal:8201    follower    true
# vault-2    vault-2.vault-internal:8201    follower    true
```

### 2. Raft Cluster Health
```bash
# Check which node is leader
kubectl exec -n vault-core vault-0 -- vault status | grep "HA Mode"
kubectl exec -n vault-core vault-1 -- vault status | grep "HA Mode"
kubectl exec -n vault-core vault-2 -- vault status | grep "HA Mode"

# Confirm every pod is unsealed
for p in 0 1 2; do
  kubectl exec vault-$p -n vault-core -- vault status | grep Sealed
done
# All lines must show "Sealed false"
```

## Server Troubleshooting

### Common Server Issues

**1. Pods not starting**
```bash
# Check pod events
kubectl describe pod vault-0 -n vault-core

# Check resource constraints
kubectl get pods -n vault-core -o wide

# View detailed pod information
kubectl get pod vault-0 -n vault-core -o yaml
```

**2. License issues**
```bash
# Check if license secret exists
kubectl get secret -n vault-core | grep license

# Verify license is mounted
kubectl exec -n vault-core vault-0 -- ls -la /vault/userconfig/vault-license/

# Check license in logs
kubectl logs -n vault-core vault-0 | grep -i "license"
```

**3. TLS/Certificate issues**
```bash
# Check TLS secret exists
kubectl get secret -n vault-core | grep tls

# Verify certificates are mounted
kubectl exec -n vault-core vault-0 -- ls -la /vault/userconfig/vault-tls/
kubectl exec -n vault-core vault-0 -- ls -la /vault/clientconfig/vault-tls/

# Test certificate validity
kubectl exec -n vault-core vault-0 -- openssl x509 -in /vault/userconfig/vault-tls/tls.crt -text -noout
```

**4. KMS/Unsealing issues**
```bash
# Check AWS credentials
kubectl get configmap -n vault-core | grep aws

# Verify KMS access from pod
kubectl exec -n vault-core vault-0 -- aws sts get-caller-identity

# Check unseal status
kubectl exec -n vault-core vault-0 -- vault status | grep Sealed
```

**5. Raft consensus issues**
```bash
# Check Raft logs
kubectl logs -n vault-core vault-0 | grep -i "raft\|consensus\|leader"

# Verify all nodes can communicate
kubectl exec -n vault-core vault-0 -- nslookup vault-1.vault-internal
kubectl exec -n vault-core vault-0 -- nslookup vault-2.vault-internal
```

### Server Restart and Recovery

**Restart individual pod:**
```bash
kubectl delete pod vault-0 -n vault-core
# Pod will be recreated automatically by StatefulSet
```

**Restart entire Vault deployment:**
```bash
kubectl rollout restart statefulset/vault -n vault-core
```

**Test HA failover:**
```bash
kubectl delete pod vault-0 -n vault-core
sleep 30
kubectl exec vault-1 -n vault-core -- vault operator raft list-peers
```

## Server Monitoring

### 1. Real-time Monitoring
```bash
# Watch pod status
kubectl get pods -n vault-core -w

# Monitor resource usage
kubectl top pods -n vault-core

# Monitor events
kubectl get events -n vault-core --sort-by='.lastTimestamp'
```

### 2. Log Monitoring
```bash
# Tail logs from all Vault pods
kubectl logs -n vault-core -l app.kubernetes.io/name=vault -f

# Monitor specific error patterns
kubectl logs -n vault-core vault-0 | grep -i "error\|warn\|fail"
```

## Complete Server Deployment Workflow

```bash
# 1. Prerequisites
task deploy STACK=common LAYER=base
task deploy STACK=helm LAYER=ingress-nginx

# 2. Deploy Vault Server
task deploy STACK=helm LAYER=vault-core

# 3. Verify Server Deployment
kubectl get pods -n vault-core
kubectl logs -n vault-core vault-0

# 4. Initialize Server (first time only)
kubectl exec -it vault-0 -n vault-core -- vault operator init

# 5. Join cluster members
kubectl exec -it vault-1 -n vault-core -- vault operator raft join \
  -leader-ca-cert="$(kubectl exec vault-1 -n vault-core -- cat /vault/userconfig/vault-tls/ca.crt)" \
  -leader-client-cert="$(kubectl exec vault-1 -n vault-core -- cat /vault/clientconfig/vault-tls/tls.crt)" \
  -leader-client-key="$(kubectl exec vault-1 -n vault-core -- cat /vault/clientconfig/vault-tls/tls.key)" \
  https://vault-0.vault-internal:8200

kubectl exec -it vault-2 -n vault-core -- vault operator raft join \
  -leader-ca-cert="$(kubectl exec vault-2 -n vault-core -- cat /vault/userconfig/vault-tls/ca.crt)" \
  -leader-client-cert="$(kubectl exec vault-2 -n vault-core -- cat /vault/clientconfig/vault-tls/tls.crt)" \
  -leader-client-key="$(kubectl exec vault-2 -n vault-core -- cat /vault/clientconfig/vault-tls/tls.key)" \
  https://vault-0.vault-internal:8200

# 6. Verify Cluster Status
kubectl exec -n vault-core vault-0 -- vault operator raft list-peers

# 7. Monitor Server Health
kubectl logs -n vault-core -l app.kubernetes.io/name=vault -f
```

Your Vault Enterprise server cluster is now deployed and ready for configuration!

## Next Steps

- Configure authentication methods
- Set up secret engines  
- Create policies for access control
- Enable audit logging
- Set up monitoring and alerting
- Configure client access (separate guide)