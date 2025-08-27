resource "aws_kms_key" "unseal" {
  count = var.is_kms_unseal_enabled ? 1 : 0
  description             = "KMS key used to unseal vault clusters"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags = local.aws_tags
}


resource "aws_kms_alias" "unseal" {
  count = var.is_kms_unseal_enabled ? 1 : 0
  name          = var.kms_unseal_key_alias
  target_key_id = aws_kms_key.unseal[0].key_id
}