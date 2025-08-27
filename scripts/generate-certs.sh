#!/bin/bash
set -e

echo "🔧 Generating certificates with separate CAs (OpenSSL 3.x compatible)..."

# Clean up previous certificates
rm -f *.crt *.key *.csr *.srl

echo "📜 Step 1: Generate Server CA"
openssl genrsa -out server-ca.key 4096
openssl req -x509 -new -nodes -key server-ca.key -sha256 -days 365 -config server-ca.cnf -out server-ca.crt
echo "✅ Server CA created"

echo "📜 Step 2: Generate Client CA"
openssl genrsa -out client-ca.key 4096
openssl req -x509 -new -nodes -key client-ca.key -sha256 -days 365 -config client-ca.cnf -out client-ca.crt
echo "✅ Client CA created"

echo "🖥️  Step 3: Generate Server Certificate (signed by Server CA)"
# Generate private key and CSR with v3_req extensions (no authorityKeyIdentifier)
openssl req -new -nodes -newkey rsa:4096 -keyout server.key -out server.csr -config server.cnf -reqexts v3_req

# Sign CSR with Server CA and apply v3_extensions (includes authorityKeyIdentifier)
openssl x509 -req -in server.csr -extensions v3_extensions -extfile server.cnf -CA server-ca.crt -CAkey server-ca.key -CAcreateserial -out server.crt -days 365 -sha256
echo "✅ Server certificate created and signed by Server CA"

echo "👤 Step 4: Generate Client Certificate (signed by Client CA)"
# Generate private key and CSR with v3_req extensions (no authorityKeyIdentifier)
openssl req -new -nodes -newkey rsa:4096 -keyout client.key -out client.csr -config client.cnf -reqexts v3_req

# Sign CSR with Client CA and apply v3_extensions (includes authorityKeyIdentifier)
openssl x509 -req -in client.csr -extensions v3_extensions -extfile client.cnf -CA client-ca.crt -CAkey client-ca.key -CAcreateserial -out client.crt -days 365 -sha256
echo "✅ Client certificate created and signed by Client CA"

echo "🔍 Step 5: Verify certificates"
echo "Server certificate verification:"
openssl verify -CAfile server-ca.crt server.crt

echo "Client certificate verification:"
openssl verify -CAfile client-ca.crt client.crt

echo "📋 Certificate details:"
echo "Server CA Subject:"
openssl x509 -in server-ca.crt -noout -subject

echo "Client CA Subject:"
openssl x509 -in client-ca.crt -noout -subject

echo "Server Certificate Subject and Extensions:"
openssl x509 -in server.crt -noout -subject -ext subjectAltName -ext extendedKeyUsage

echo "Client Certificate Subject and Extensions:"
openssl x509 -in client.crt -noout -subject -ext extendedKeyUsage

echo "🎉 All certificates generated successfully!"
