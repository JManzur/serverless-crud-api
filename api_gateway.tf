# In this demo no quota_settings neither throttle_settings are set up
# More info: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan

# Capture the AWS Account ID:
data "aws_caller_identity" "current" {}

# API Gateway definition:
resource "aws_api_gateway_rest_api" "serverless_crud_api" {
  name        = var.apigw_name
  description = "Serverless CRUD API Gateway"
  endpoint_configuration {
    types = ["EDGE"]
  }

  depends_on = [
    aws_lambda_function.crud_api_function
  ]
}

# ---------------------------------------------------
# API Resources definition:
# ---------------------------------------------------

# /create Resource
resource "aws_api_gateway_resource" "create" {
  rest_api_id = aws_api_gateway_rest_api.serverless_crud_api.id
  parent_id   = aws_api_gateway_rest_api.serverless_crud_api.root_resource_id
  path_part   = "create"
}

# /read Resource
resource "aws_api_gateway_resource" "read" {
  rest_api_id = aws_api_gateway_rest_api.serverless_crud_api.id
  parent_id   = aws_api_gateway_rest_api.serverless_crud_api.root_resource_id
  path_part   = "read"
}

# /update Resource
resource "aws_api_gateway_resource" "update" {
  rest_api_id = aws_api_gateway_rest_api.serverless_crud_api.id
  parent_id   = aws_api_gateway_rest_api.serverless_crud_api.root_resource_id
  path_part   = "update"
}

# /delete Resource
resource "aws_api_gateway_resource" "delete" {
  rest_api_id = aws_api_gateway_rest_api.serverless_crud_api.id
  parent_id   = aws_api_gateway_rest_api.serverless_crud_api.root_resource_id
  path_part   = "delete"
}

# API Model Schema definition:
resource "aws_api_gateway_model" "json_schema" {
  rest_api_id  = aws_api_gateway_rest_api.serverless_crud_api.id
  name         = "passthrough"
  description  = "a JSON schema"
  content_type = "application/json"

  schema = file("templates/passthrough.template")
}

# ---------------------------------------------------
# POST Method:
# ---------------------------------------------------

# POST Request method:
resource "aws_api_gateway_method" "post" {
  rest_api_id      = aws_api_gateway_rest_api.serverless_crud_api.id
  resource_id      = aws_api_gateway_resource.create.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true

  request_models = {
    "application/json" = aws_api_gateway_model.json_schema.name
  }
}

# POST Request integration:
resource "aws_api_gateway_integration" "integration-post" {
  rest_api_id             = aws_api_gateway_rest_api.serverless_crud_api.id
  resource_id             = aws_api_gateway_resource.create.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.crud_api_function.invoke_arn

  request_templates = {
    "application/json" = "${file("templates/POST.template")}"
  }
}

# POST Method Response
resource "aws_api_gateway_method_response" "post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.serverless_crud_api.id
  resource_id = aws_api_gateway_resource.create.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

# POST Integration Response
resource "aws_api_gateway_integration_response" "post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.serverless_crud_api.id
  resource_id = aws_api_gateway_resource.create.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = aws_api_gateway_method_response.post_response_200.status_code

  response_templates = {
    "application/json" = "${file("templates/lambda-response.template")}"
  }

  depends_on = [
    aws_api_gateway_integration.integration-post
  ]
}

# ---------------------------------------------------
# GET Method:
# ---------------------------------------------------

# GET Request method:
resource "aws_api_gateway_method" "get" {
  rest_api_id      = aws_api_gateway_rest_api.serverless_crud_api.id
  resource_id      = aws_api_gateway_resource.read.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

# GET Request integration:
resource "aws_api_gateway_integration" "integration-get" {
  rest_api_id             = aws_api_gateway_rest_api.serverless_crud_api.id
  resource_id             = aws_api_gateway_resource.read.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST" // Lambda function only accepts POST
  type                    = "AWS"
  uri                     = aws_lambda_function.crud_api_function.invoke_arn

  request_templates = {
    "application/json" = "${file("templates/GET.template")}"
  }
}

# GET Method Response
resource "aws_api_gateway_method_response" "get_response_200" {
  rest_api_id = aws_api_gateway_rest_api.serverless_crud_api.id
  resource_id = aws_api_gateway_resource.read.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

# GET Integration Response
resource "aws_api_gateway_integration_response" "get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.serverless_crud_api.id
  resource_id = aws_api_gateway_resource.read.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = aws_api_gateway_method_response.get_response_200.status_code

  response_templates = {
    "application/json" = "${file("templates/lambda-response.template")}"
  }

  depends_on = [
    aws_api_gateway_integration.integration-get
  ]
}

# ---------------------------------------------------
# PUT Method:
# ---------------------------------------------------

# PUT Request method:
resource "aws_api_gateway_method" "put" {
  rest_api_id      = aws_api_gateway_rest_api.serverless_crud_api.id
  resource_id      = aws_api_gateway_resource.update.id
  http_method      = "PUT"
  authorization    = "NONE"
  api_key_required = true
}

# PUT Request integration:
resource "aws_api_gateway_integration" "integration-put" {
  rest_api_id             = aws_api_gateway_rest_api.serverless_crud_api.id
  resource_id             = aws_api_gateway_resource.update.id
  http_method             = aws_api_gateway_method.put.http_method
  integration_http_method = "POST" // Lambda function only accepts POST
  type                    = "AWS"
  uri                     = aws_lambda_function.crud_api_function.invoke_arn

  request_templates = {
    "application/json" = "${file("templates/PUT.template")}"
  }
}

# PUT Method Response
resource "aws_api_gateway_method_response" "put_response_200" {
  rest_api_id = aws_api_gateway_rest_api.serverless_crud_api.id
  resource_id = aws_api_gateway_resource.update.id
  http_method = aws_api_gateway_method.put.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

# PUT Integration Response
resource "aws_api_gateway_integration_response" "put_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.serverless_crud_api.id
  resource_id = aws_api_gateway_resource.update.id
  http_method = aws_api_gateway_method.put.http_method
  status_code = aws_api_gateway_method_response.put_response_200.status_code

  response_templates = {
    "application/json" = "${file("templates/lambda-response.template")}"
  }

  depends_on = [
    aws_api_gateway_integration.integration-get
  ]
}

# ---------------------------------------------------
# DELETE Method:
# ---------------------------------------------------

# DELETE Request method:
resource "aws_api_gateway_method" "delete" {
  rest_api_id      = aws_api_gateway_rest_api.serverless_crud_api.id
  resource_id      = aws_api_gateway_resource.delete.id
  http_method      = "DELETE"
  authorization    = "NONE"
  api_key_required = true
}

# DELETE Request integration:
resource "aws_api_gateway_integration" "integration-delete" {
  rest_api_id             = aws_api_gateway_rest_api.serverless_crud_api.id
  resource_id             = aws_api_gateway_resource.delete.id
  http_method             = aws_api_gateway_method.delete.http_method
  integration_http_method = "POST" // Lambda function only accepts POST
  type                    = "AWS"
  uri                     = aws_lambda_function.crud_api_function.invoke_arn

  request_templates = {
    "application/json" = "${file("templates/DELETE.template")}"
  }
}

# DELETE Method Response
resource "aws_api_gateway_method_response" "delete_response_200" {
  rest_api_id = aws_api_gateway_rest_api.serverless_crud_api.id
  resource_id = aws_api_gateway_resource.delete.id
  http_method = aws_api_gateway_method.delete.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

# DELETE Integration Response
resource "aws_api_gateway_integration_response" "delete_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.serverless_crud_api.id
  resource_id = aws_api_gateway_resource.delete.id
  http_method = aws_api_gateway_method.delete.http_method
  status_code = aws_api_gateway_method_response.delete_response_200.status_code

  response_templates = {
    "application/json" = "${file("templates/lambda-response.template")}"
  }

  depends_on = [
    aws_api_gateway_integration.integration-delete
  ]
}

# ---------------------------------------------------
# Stages, API-Key and Usage Plan
# ---------------------------------------------------

# Stage PROD definition:
resource "aws_api_gateway_stage" "v1" {
  deployment_id = aws_api_gateway_deployment.crud_api.id
  rest_api_id   = aws_api_gateway_rest_api.serverless_crud_api.id
  stage_name    = "v1"
}

# API-Key generation: 
resource "aws_api_gateway_api_key" "crud_api_key" {
  name        = "crud_api_key"
  description = "Serverless CRUD API API-Key"
  enabled     = true
  tags        = merge(var.project-tags, { Name = "${var.resource-name-tag}-api-key" })
}

# Usage plan definition:
resource "aws_api_gateway_usage_plan" "crud_api_usage_plan" {
  name = "crud_api_usage_plan"
  tags = merge(var.project-tags, { Name = "${var.resource-name-tag}-usage_plan" })

  api_stages {
    api_id = aws_api_gateway_rest_api.serverless_crud_api.id
    stage  = aws_api_gateway_stage.v1.stage_name
  }
}

# Declare the API key in the usage plan:
resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.crud_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.crud_api_usage_plan.id
}

# ---------------------------------------------------
# Lambda Triggers:
# ---------------------------------------------------

# POST Trigger:
resource "aws_lambda_permission" "lambda_post_permission" {
  statement_id  = "InvokePOSTCRUDAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.crud_api_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.serverless_crud_api.id}/*/${aws_api_gateway_method.post.http_method}/${aws_api_gateway_resource.create.path_part}"

  depends_on = [
    aws_lambda_function.crud_api_function,
    aws_api_gateway_rest_api.serverless_crud_api
  ]
}

# GET Trigger:
resource "aws_lambda_permission" "lambda_get_permission" {
  statement_id  = "InvokeGETCRUDAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.crud_api_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.serverless_crud_api.id}/*/${aws_api_gateway_method.get.http_method}/${aws_api_gateway_resource.read.path_part}"

  depends_on = [
    aws_lambda_function.crud_api_function,
    aws_api_gateway_rest_api.serverless_crud_api
  ]
}

# PUT Trigger:
resource "aws_lambda_permission" "lambda_put_permission" {
  statement_id  = "InvokePUTCRUDAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.crud_api_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.serverless_crud_api.id}/*/${aws_api_gateway_method.put.http_method}/${aws_api_gateway_resource.update.path_part}"

  depends_on = [
    aws_lambda_function.crud_api_function,
    aws_api_gateway_rest_api.serverless_crud_api
  ]
}

# DELETE Trigger:
resource "aws_lambda_permission" "lambda_delete_permission" {
  statement_id  = "InvokeDELETECRUDAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.crud_api_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.serverless_crud_api.id}/*/${aws_api_gateway_method.delete.http_method}/${aws_api_gateway_resource.delete.path_part}"

  depends_on = [
    aws_lambda_function.crud_api_function,
    aws_api_gateway_rest_api.serverless_crud_api
  ]
}

# ---------------------------------------------------
# Deploy the API
# ---------------------------------------------------
resource "aws_api_gateway_deployment" "crud_api" {
  rest_api_id = aws_api_gateway_rest_api.serverless_crud_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.serverless_crud_api.id,
      aws_api_gateway_method.post.id,
      aws_api_gateway_integration.integration-post.id,
      aws_api_gateway_method.get.id,
      aws_api_gateway_integration.integration-get.id,
      aws_api_gateway_method.put.id,
      aws_api_gateway_integration.integration-put.id,
      aws_api_gateway_method.delete.id,
      aws_api_gateway_integration.integration-delete.id
    ]))
  }

  depends_on = [
    aws_api_gateway_method.post,
    aws_api_gateway_method.get,
    aws_api_gateway_method.put,
    aws_api_gateway_method.delete,
    aws_api_gateway_integration.integration-post,
    aws_api_gateway_integration.integration-get,
    aws_api_gateway_integration.integration-put,
    aws_api_gateway_integration.integration-delete,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------
# Printing the outputs:
# ---------------------------------------------------
output "complete_invoke_url" {
  value = [
    "${aws_api_gateway_deployment.crud_api.invoke_url}${aws_api_gateway_stage.v1.stage_name}/${aws_api_gateway_resource.create.path_part}",
    "${aws_api_gateway_deployment.crud_api.invoke_url}${aws_api_gateway_stage.v1.stage_name}/${aws_api_gateway_resource.read.path_part}",
    "${aws_api_gateway_deployment.crud_api.invoke_url}${aws_api_gateway_stage.v1.stage_name}/${aws_api_gateway_resource.update.path_part}",
    "${aws_api_gateway_deployment.crud_api.invoke_url}${aws_api_gateway_stage.v1.stage_name}/${aws_api_gateway_resource.delete.path_part}"
  ]
  description = "API Gateway Invoke URL"
}

# Use the "-raw" command to view the API key: "terraform output -raw api_key"
output "api_key" {
  value     = aws_api_gateway_api_key.crud_api_key.value
  sensitive = true
  description = "API-Key"
}