resource "aws_kms_key" "unseal" {
  description             = "KMS key used to unseal vault clusters"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags = local.aws_tags
}


resource "aws_kms_alias" "unseal" {
  name          = "alias/vault-unseal"
  target_key_id = aws_kms_key.unseal.key_id
}