# hcv-lab-local

## Overview

`hcv-lab-local` is an infrastructure-as-code repository for deploying and managing a secure HashiCorp Vault lab environment on Kubernetes. It leverages Terraform, Helm, and Taskfile automation to provision core components such as Vault, NGINX Ingress Controller, and supporting resources like Certificate Authority (CA) and AWS KMS for unsealing.

This repository is modular, with reusable layers and modules for rapid, consistent, and secure deployments.

---

## Documentation

- [Certificate Authority (CA) and AWS KMS Integration for Vault](docs/base.md)  
  Learn how the base layer provisions a CA for Vault TLS and an AWS KMS key for Vault unsealing.

- [Helm Base Module](docs/helm.md)  
  Understand the reusable Helm deployment logic used for all Helm-based components.

- [Ingress-NGINX Controller Deployment](docs/ingress-nginx.md)  
  Details on deploying the NGINX Ingress Controller using Helm and Terraform.

- [How to Use Taskfile.yml](docs/taskfile.md)  
  Step-by-step guide for automating Terraform operations with Taskfile.

- [Vault CLI Client Setup with TLS on Kubernetes](docs/vault/client.md)  
  Instructions for installing and configuring the Vault CLI to connect securely to your Vault server.

- [Vault-Core Deployment](docs/vault/server.md)  
  In-depth documentation on deploying and configuring the Vault-Core layer using Helm and Terraform.

---

## Quick Start

1. Clone this repository.
2. Review the [Taskfile usage guide](docs/taskfile.md) to understand available automation commands.
3. Deploy the base infrastructure, ingress controller, and Vault using the provided tasks.
4. Refer to the documentation above for advanced configuration and troubleshooting.

---

## Contributing

Contributions and improvements are welcome! Please see the documentation for module and layer structure before submitting changes.

---

For more details, explore the linked documentation files in the `docs/` directory.