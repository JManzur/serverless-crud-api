resource "aws_dynamodb_table" "dynamodb-table" {
  name           = var.table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "CustomerId"

  # Attribute are in "Scalar Types" S, N, or B for (S)tring, (N)umber or (B)inary data.
  attribute {
    name = "CustomerId"
    type = "N"
  }

  tags = merge(var.project-tags, { Name = "${var.resource-name-tag}-table" })
}