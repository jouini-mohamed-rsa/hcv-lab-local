# Import the CA from remote state
data "terraform_remote_state" "common" {
  backend = "local"

  config = {
    path = "../../../common/layers/base/terraform.tfstate"
  }
}