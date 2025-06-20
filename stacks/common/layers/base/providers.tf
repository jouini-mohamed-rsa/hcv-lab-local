provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  config_path    = var.kubernetes_config_path
}