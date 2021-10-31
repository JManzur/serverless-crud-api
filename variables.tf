# AWS Region: North of Virginia
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# API Name (Lambda Function Name)
variable "api_name" {
  type    = string
  default = "ServerlessCRUD-API"
}

# API Gateway Name
variable "apigw_name" {
  type    = string
  default = "ServerlessCRUD-GW"
}

# DynamoDB Table Name
variable "table_name" {
  type    = string
  default = "ServerlessCRUD-Table"
}

### Tags Variables ###

variable "project-tags" {
  type = map(string)
  default = {
    service     = "ServerlessCRUD-API",
    environment = "demo"
    owner       = "example@mail.com"
  }
}

variable "resource-name-tag" {
  type    = string
  default = "ServerlessCRUD-API"
}