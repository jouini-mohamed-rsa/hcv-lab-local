# Import the CA from remote state
data "terraform_remote_state" "lab_ca" {
  backend = "local"

  config = {
    path = "../../../common/layers/ca/terraform.tfstate"
  }
}