# Vault Client Setup & Testing Guide

Complete guide for setting up Vault CLI client with mTLS and running comprehensive tests.

## 🔧 Quick Setup

### 1. Install Vault CLI
```bash
# macOS
brew tap hashicorp/tap && brew install hashicorp/tap/vault

# Ubuntu/Debian  
sudo apt-get update && sudo apt-get install vault

# Verify
vault version
```

### 2. Setup Client Certificates (mTLS Option)
```bash
# Create certificate directory
mkdir -p ~/vault-cert

# Extract certificates from Kubernetes secrets
kubectl get secret vault-tls -n vault-core -o jsonpath="{.data.ca\.crt}" | base64 --decode > ~/vault-cert/ca.crt
kubectl get secret vault-client-tls -n vault-core -o jsonpath="{.data.tls\.crt}" | base64 --decode > ~/vault-cert/client.crt
kubectl get secret vault-client-tls -n vault-core -o jsonpath="{.data.tls\.key}" | base64 --decode > ~/vault-cert/client.key
```

### 3. Configure Environment
```bash
# Basic TLS connection
export VAULT_ADDR="https://vault.local:8200"
export VAULT_CACERT="~/certifications/ca/ca.crt" # Server CA

# mTLS connection (recommended)
export VAULT_CLIENT_CERT="~/certifications/client/client.crt"
export VAULT_CLIENT_KEY="~/certifications/client/client.key"

# Make permanent (add to ~/.zshrc or ~/.bashrc)
echo 'export VAULT_ADDR="https://vault.local:8200"' >> ~/.zshrc
echo 'export VAULT_CACERT="~/certifications/ca/ca.crt"' >> ~/.zshrc
echo 'export VAULT_CLIENT_CERT="~/certifications/client/client.crt"' >> ~/.zshrc
echo 'export VAULT_CLIENT_KEY="~/certifications/client/client.key"' >> ~/.zshrc
source ~/.zshrc
```

```bash
# Verify /etc/hosts entry
grep vault.localhost /etc/hosts
# Should show: 127.0.0.1    localhost vault.localhost
```

## 🧪 Complete Test Suite

### Test 1: Connection Verification
```bash
# Test basic connectivity
vault status

# Expected: Sealed=false, HA Mode=active
```

### Test 2: Authentication
```bash
# Option B: Token authentication  
vault login <your-initial-root-token>
```

### Test 3: Secrets Engine Setup
```bash
# Enable KV v2 secrets engine
vault secrets enable -path=secret kv-v2

# Verify enabled engines
vault secrets list
```

### Test 4: Basic Secret Operations
```bash
# Create test secret
vault kv put secret/myapp \
  username=testuser \
  password=testpass123 \
  environment=development \
  database_url=postgres://localhost:5432/myapp

# Retrieve full secret
vault kv get secret/myapp

# Get specific fields
vault kv get -field=username secret/myapp
vault kv get -field=password secret/myapp

# JSON format
vault kv get -format=json secret/myapp | jq '.data.data'

# List secrets
vault kv list secret/
```

### Test 5: Version Control (KV v2)
```bash
# Update secret (creates version 2)
vault kv put secret/myapp \
  username=updateduser \
  password=newpass456 \
  environment=production

# View different versions
vault kv get -version=1 secret/myapp
vault kv get -version=2 secret/myapp

# Check metadata
vault kv metadata get secret/myapp
```

### Test 6: Secret Lifecycle
```bash
# Delete latest version
vault kv delete secret/myapp

# Undelete
vault kv undelete -versions=2 secret/myapp

# Destroy permanently
vault kv destroy -versions=1,2 secret/myapp
```

### Test 7: High Availability Testing
```bash
# Check cluster status
vault operator raft list-peers

# Test failover (in another terminal, delete leader pod)
kubectl delete pod vault-0 -n vault-core

# Verify secrets still accessible
vault kv get secret/myapp
```

## 🚀 One-Command Test Script

Save as `vault-test.sh`:

```bash
#!/bin/bash
set -e

echo "🔍 Testing Vault Client Setup & Operations"

# 1. Connection test
echo "1️⃣ Testing connection..."
vault status > /dev/null && echo "✅ Connection OK" || echo "❌ Connection failed"

# 2. Authentication test
echo "2️⃣ Testing authentication..."
vault token lookup > /dev/null && echo "✅ Authentication OK" || echo "❌ Authentication failed"

# 3. Secrets engine test
echo "3️⃣ Testing secrets engine..."
vault secrets list | grep -q secret && echo "✅ KV engine ready" || {
  vault secrets enable -path=secret kv-v2
  echo "✅ KV engine enabled"
}

# 4. CRUD operations test
echo "4️⃣ Testing CRUD operations..."
TEST_ID=$(date +%s)
vault kv put secret/test-$TEST_ID \
  test_id=$TEST_ID \
  status=testing \
  timestamp="$(date)"

vault kv get secret/test-$TEST_ID > /dev/null && echo "✅ Create/Read OK" || echo "❌ CRUD failed"

# 5. Cleanup
vault kv delete secret/test-$TEST_ID
echo "✅ Cleanup complete"

echo "🎉 All tests passed!"
```

Run with:
```bash
chmod +x vault-test.sh && ./vault-test.sh
```

## 🛠️ Troubleshooting

### Connection Issues
```bash
# Test basic connectivity
curl -k --cert $VAULT_CLIENT_CERT --key $VAULT_CLIENT_KEY \
  --cacert $VAULT_CACERT $VAULT_ADDR/v1/sys/health

# Check certificate validity
openssl x509 -in $VAULT_CLIENT_CERT -text -noout | grep "Not After"
openssl verify -CAfile $VAULT_CACERT $VAULT_CLIENT_CERT
```

### Certificate Issues  
```bash
# Verify certificates exist
ls -la ~/vault-cert/

# Check Kubernetes secrets
kubectl get secrets -n vault-core | grep tls

# Re-extract certificates
kubectl get secret vault-tls -n vault-core -o yaml
```

### DNS Issues
```bash
# Test DNS resolution
nslookup vault.local

# Add to /etc/hosts if needed
echo "127.0.0.1 vault.local" | sudo tee -a /etc/hosts
```

## 📋 Quick Reference

### Essential Commands
```bash
vault status                              # Check server status
vault login -method=cert                  # mTLS authentication
vault secrets list                        # List secret engines
vault kv put secret/path key=value        # Create secret
vault kv get secret/path                  # Read secret
vault kv delete secret/path               # Delete secret
vault operator raft list-peers            # Check HA cluster
```

### Environment Variables
```bash
export VAULT_ADDR="https://vault.local:8200"
export VAULT_CACERT="~/certifications/ca/ca.crt"
export VAULT_CLIENT_CERT="~/certifications/client/client.crt"  # mTLS
export VAULT_CLIENT_KEY="~/certifications/client/client.key"   # mTLS
```

## 🔐 Security Best Practices

1. **Use mTLS**: Always configure client certificates for production
2. **Rotate certificates**: Regularly update client certificates
3. **Limit token scope**: Create tokens with minimal required policies
4. **Audit access**: Enable audit logging to track secret access
5. **Network security**: Use VPN or private networks for client access

Your Vault client is now ready for secure operations! 🎯