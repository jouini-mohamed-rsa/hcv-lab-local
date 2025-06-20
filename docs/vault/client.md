# 🧰 Vault CLI Client Setup with TLS on Kubernetes

This guide walks you through installing and configuring the Vault CLI to connect to a Vault server exposed via Ingress (`https://vault.localhost`) secured with TLS.

---

## 📦 Prerequisites

- A running Kubernetes cluster (e.g., Minikube, Docker Desktop, or EKS)
- Vault server deployed in the namespace (e.g., `vault-core`)
- Ingress configured to expose `vault.localhost` with TLS
- Kubernetes TLS secret available (e.g., `vault-tls`)
- Ingress controller installed (e.g., `ingress-nginx`)

---

## 🔐 Step 1: Export the Vault CA Certificate

Extract the TLS certificate from the Kubernetes TLS secret.

### 🧾 If your TLS secret has a CA certificate:

```bash
mkdir -p ~/vault-cert
kubectl get secret vault-tls -n vault-core -o jsonpath="{.data.ca\.crt}" | base64 --decode > ~/vault-ca.crt
```

## 📥 Step 2: Install the Vault CLI

### 🖥️ macOS

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/vault
```

### 🐧 Ubuntu/Debian

```bash
sudo apt-get update && sudo apt-get install vault
```

### ✅ Verify the Installation
```bash
vault version
```

## ⚙️ Step 3: Configure the Vault CLI

You can configure the CLI either for the current shell session or permanently.

### 🕒 Option A: Temporary (Current Session Only)


```bash
export VAULT_ADDR=https://vault.localhost
export VAULT_CACERT=~/vault-ca.crt
```

### 📌 Option B: Permanent (Shell Profile)

Append these lines to your shell config file (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
export VAULT_ADDR=https://vault.localhost
export VAULT_CACERT=~/vault-ca.crt
```

Then apply the changes:

```bash
source ~/.zshrc   # or ~/.bashrc
```

## ✅ Step 4: Verify Connection
Run the following to confirm the Vault CLI is configured properly:

```bash
vault status
```

Expected output:

```text
Key                      Value
---                      -----
Seal Type                awskms
Recovery Seal Type       shamir
Initialized              true
Sealed                   false
Total Recovery Shares    5
Threshold                3
Version                  1.19.5+ent
Build Date               2025-05-29T09:17:15Z
Storage Type             raft
Cluster Name             vault-integrated-storage
Cluster ID               xxxxxxxx-xxxxx-xxxxx-xxxxxx-xxxxxxx
Removed From Cluster     false
HA Enabled               true
HA Cluster               https://vault-1.vault-internal:8201
HA Mode                  active
Active Since             2025-06-19T15:26:08.852044381Z
Raft Committed Index     25614
Raft Applied Index       25614
Last WAL                 9829
```