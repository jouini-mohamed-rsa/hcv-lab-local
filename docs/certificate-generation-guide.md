# Self-Signed Certificate Generation Guide

Complete guide for generating self-signed certificates with separate Certificate Authorities for TLS and mTLS authentication.

## Overview

This guide demonstrates how to create a complete PKI setup with:
- **Server CA**: Used by clients to verify server certificates
- **Client CA**: Used by servers to verify client certificates (for mTLS)
- **Server Certificates**: For server authentication
- **Client Certificates**: For client authentication in mTLS scenarios

## 🏗️ Project Structure

```bash
mkdir -p certificates
cd certificates
```

## 📋 Certificate Configuration Files

### 1. Server CA Configuration

Create `server-ca.cnf`:
```ini
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_extensions
prompt = no

[req_distinguished_name]
C = US
ST = CA
L = San Francisco
O = Server Organization
OU = Server CA Unit
CN = Server Root CA

[v3_extensions]
basicConstraints = CA:TRUE
keyUsage = keyCertSign, cRLSign
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
```

### 2. Client CA Configuration

Create `client-ca.cnf`:
```ini
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_extensions
prompt = no

[req_distinguished_name]
C = US
ST = NY
L = New York
O = Client Organization
OU = Client CA Unit
CN = Client Root CA

[v3_extensions]
basicConstraints = CA:TRUE
keyUsage = keyCertSign, cRLSign
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
```

### 3. Server Certificate Configuration

Create `server.cnf`:
```ini
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
x509_extensions = v3_extensions
prompt = no

[req_distinguished_name]
C = US
ST = CA
L = San Francisco
O = Server Organization
OU = Server Unit
CN = vault.local

[v3_req]
# Extensions for CSR - no authorityKeyIdentifier
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[v3_extensions]
# Extensions for final certificate - includes authorityKeyIdentifier
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer

[alt_names]
DNS.1 = vault.local
DNS.2 = *.vault.local
DNS.3 = localhost
DNS.4 = *.localhost
IP.1 = 127.0.0.1
IP.2 = ::1
```

### 4. Client Certificate Configuration

Create `client.cnf`:
```ini
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
x509_extensions = v3_extensions
prompt = no

[req_distinguished_name]
C = US
ST = NY
L = New York
O = Client Organization
OU = Client Unit
CN = vault-client

[v3_req]
# Extensions for CSR - no authorityKeyIdentifier
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyAgreement
extendedKeyUsage = clientAuth

[v3_extensions]
# Extensions for final certificate - includes authorityKeyIdentifier
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyAgreement
extendedKeyUsage = clientAuth
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
```

## 🔧 Certificate Generation

The certificate generation script is available at `scripts/generate-certs.sh`.

### Using the Existing Script

```bash
# Copy the script to your certificates directory
cp scripts/generate-certs.sh .

# Make it executable
chmod +x generate-certs.sh

# Run the script
./generate-certs.sh
```

### Manual Step-by-Step Generation

If you prefer to run commands manually:

#### Step 1: Generate Server CA
```bash
# Generate Server CA private key
openssl genrsa -out server-ca.key 4096

# Generate Server CA certificate
openssl req -x509 -new -nodes -key server-ca.key -sha256 -days 365 -config server-ca.cnf -out server-ca.crt
```

#### Step 2: Generate Client CA
```bash
# Generate Client CA private key
openssl genrsa -out client-ca.key 4096

# Generate Client CA certificate
openssl req -x509 -new -nodes -key client-ca.key -sha256 -days 365 -config client-ca.cnf -out client-ca.crt
```

#### Step 3: Generate Server Certificate
```bash
# Generate server private key and CSR
openssl req -new -nodes -newkey rsa:4096 -keyout server.key -out server.csr -config server.cnf -reqexts v3_req

# Sign server CSR with Server CA
openssl x509 -req -in server.csr -extensions v3_extensions -extfile server.cnf -CA server-ca.crt -CAkey server-ca.key -CAcreateserial -out server.crt -days 365 -sha256
```

#### Step 4: Generate Client Certificate
```bash
# Generate client private key and CSR
openssl req -new -nodes -newkey rsa:4096 -keyout client.key -out client.csr -config client.cnf -reqexts v3_req

# Sign client CSR with Client CA
openssl x509 -req -in client.csr -extensions v3_extensions -extfile client.cnf -CA client-ca.crt -CAkey client-ca.key -CAcreateserial -out client.crt -days 365 -sha256
```

## ✅ Verification

### Verify Certificate Chain
```bash
# Verify server certificate against Server CA
openssl verify -CAfile server-ca.crt server.crt

# Verify client certificate against Client CA
openssl verify -CAfile client-ca.crt client.crt
```

### Check Certificate Details
```bash
# Server CA details
echo "=== Server CA ==="
openssl x509 -in server-ca.crt -noout -subject -issuer -dates

# Client CA details  
echo "=== Client CA ==="
openssl x509 -in client-ca.crt -noout -subject -issuer -dates

# Server certificate details
echo "=== Server Certificate ==="
openssl x509 -in server.crt -noout -subject -issuer -dates -ext subjectAltName -ext extendedKeyUsage

# Client certificate details
echo "=== Client Certificate ==="
openssl x509 -in client.crt -noout -subject -issuer -dates -ext extendedKeyUsage
```

### Test Certificate Validity
```bash
# Check if certificates are properly signed
openssl verify -verbose -CAfile server-ca.crt server.crt
openssl verify -verbose -CAfile client-ca.crt client.crt

# Check certificate chain
openssl x509 -in server.crt -text -noout | grep -A 2 "Authority Key Identifier"
openssl x509 -in client.crt -text -noout | grep -A 2 "Authority Key Identifier"
```

## 📁 Generated Files

After running the script, you'll have:

```
certificates/
├── server-ca.cnf       # Server CA configuration
├── client-ca.cnf       # Client CA configuration  
├── server.cnf          # Server certificate configuration
├── client.cnf          # Client certificate configuration
├── server-ca.key       # Server CA private key
├── server-ca.crt       # Server CA certificate
├── client-ca.key       # Client CA private key
├── client-ca.crt       # Client CA certificate
├── server.key          # Server private key
├── server.crt          # Server certificate
├── server.csr          # Server certificate signing request
├── client.key          # Client private key
├── client.crt          # Client certificate
├── client.csr          # Client certificate signing request
├── server-ca.srl       # Server CA serial number
└── client-ca.srl       # Client CA serial number
```

## 🔐 Usage in Applications

### For TLS-only (Server Authentication)
- **Server**: Use `server.crt` and `server.key`
- **Client**: Use `server-ca.crt` to verify server

### For mTLS (Mutual Authentication)
- **Server**: Use `server.crt`, `server.key`, and `client-ca.crt`
- **Client**: Use `client.crt`, `client.key`, and `server-ca.crt`

## 🛡️ Security Best Practices

1. **Protect Private Keys**: Store CA private keys securely and limit access
2. **Certificate Expiry**: Set appropriate validity periods (365 days in examples)
3. **Key Size**: Use 4096-bit RSA keys for better security
4. **Subject Alternative Names**: Include all necessary DNS names and IPs
5. **Purpose-specific CAs**: Use separate CAs for different purposes
6. **Regular Rotation**: Plan for certificate rotation before expiry

## 🔄 Certificate Renewal

To renew certificates before expiry:

```bash
# Check expiry dates
openssl x509 -in server.crt -noout -dates
openssl x509 -in client.crt -noout -dates

# Regenerate certificates (keep same CA)
./generate-certs.sh
```

## 🧪 Quick Test

Test your certificates with OpenSSL:

```bash
# Start a test server
openssl s_server -accept 8443 -cert server.crt -key server.key -CAfile client-ca.crt -verify 2

# Test with client certificate
openssl s_client -connect localhost:8443 -cert client.crt -key client.key -CAfile server-ca.crt
```

Your self-signed certificate infrastructure is now ready for TLS and mTLS implementations! 🎯