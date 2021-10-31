# Zip the lambda code
data "archive_file" "init" {
  type        = "zip"
  source_dir  = "lambda_code/"
  output_path = "output_lambda_zip/crud_api.zip"
}

# Create lambda function
resource "aws_lambda_function" "crud_api_function" {
  filename      = data.archive_file.init.output_path
  function_name = var.api_name
  role          = aws_iam_role.crud_api_policy_role.arn
  handler       = "main_handler.lambda_handler"
  description   = "Serverless CRUD API"
  tags          = merge(var.project-tags, { Name = "${var.resource-name-tag}-lambda" })

  # Prevent lambda recreation
  source_code_hash = filebase64sha256(data.archive_file.init.output_path)

  runtime = "python3.9"
  timeout = "120"
}