data "aws_iam_policy_document" "policy_source" {
  statement {
    sid    = "CloudWatchAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    sid    = "DynamoDBTableAccess"
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:ConditionCheckItem",
      "dynamodb:PutItem",
      "dynamodb:DescribeTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem"
    ]
    resources = [
      "${aws_dynamodb_table.dynamodb-table.arn}"
    ]
  }
}

data "aws_iam_policy_document" "role_source" {
  statement {
    sid    = "LambdaAssumeRole"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# IAM Policy: Allow Lambda to perform CRUD operations on DynamoDB Table and send Logs to CloudWatch
resource "aws_iam_policy" "crud_api_policy" {
  name        = "crud_api_policy"
  path        = "/"
  description = "CRUD API using Lambda"
  policy      = data.aws_iam_policy_document.policy_source.json
  tags        = merge(var.project-tags, { Name = "${var.resource-name-tag}-policy" }, )
}

# IAM Role: Lambda execution role
resource "aws_iam_role" "crud_api_policy_role" {
  name               = "crud_api_policy_role"
  assume_role_policy = data.aws_iam_policy_document.role_source.json
  tags               = merge(var.project-tags, { Name = "${var.resource-name-tag}-role" }, )
}

# Attach Role and Policy
resource "aws_iam_role_policy_attachment" "crud_api_attach" {
  role       = aws_iam_role.crud_api_policy_role.name
  policy_arn = aws_iam_policy.crud_api_policy.arn
}