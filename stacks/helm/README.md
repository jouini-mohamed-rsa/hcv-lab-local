### Download Vault Helm Chart Locally

Navigate to the `./helm/layers` directory and run the following commands:

```shell
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

helm pull hashicorp/vault --untar --version 0.27.0
```

This will download and extract the chart into a folder named `vault/`