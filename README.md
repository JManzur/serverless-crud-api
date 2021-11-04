# AWS Serverless CRUD API

A CRUD API is an API that can perform CREATE, READ, UPDATE, and DELETE operations on a database.

This demo is a production-ready serverless deployment, using the following architecture:

## Resources deployed by this manifest:

- Dynamodb table.
- Python lambda function (This is the API).
- Api Gateway
  - v1 Stage
  - Basic usage plan
  - API Key
  - /create (POST) resource and methods
  - /read (GET) resource and methods
  - /update (PUT) resource and methods
  - /delete (Delete) resource and methods
- IAM:
  - Lambda permissions to Create, Read, Update and Delete Items in the project's DynamoDB table.
  - Lambda permissions to send logs to CloudWatch
  - API Gateway permissions to trigger the lambda function

### Deployment diagram:

![App Screenshot](https://1.bp.blogspot.com/-dBckAkI7Zqk/YX6t-NGdxLI/AAAAAAAAFuM/twv5vWzJTvoEIilQz3IuJxXt3e83tgP2gCLcBGAsYHQ/s16000/serverless-crud-api.drawio.png)

## Tested with: 

| Environment | Application | Version  |
| ----------------- |-----------|---------|
| WSL2 Ubuntu 20.04 | Terraform | v1.0.10 |
| WSL2 Ubuntu 20.04 | aws-cli | v2.2.12 |
| WSL2 Ubuntu 20.04 | Python | 3.9.5 |

## Initialization How-To:

Located in the root directory, make an "aws configure" to log into the aws account, and a "terraform init" to download the necessary modules and start the backend.

```bash
aws configure
terraform init
```

## Deployment How-To:

Located in the root directory, make the necessary changes in the variables.tf file and run the manifests:

```bash
terraform apply
```

## Debugging / Troubleshooting:

<div align="center">
    <img src="https://1.bp.blogspot.com/-b7YyMHGBZ08/YYFHdXDqH_I/AAAAAAAAFuY/TFO2pYNrCeEkfFVtI8WVDl2LHrpxlz-BwCLcBGAsYHQ/s16000/under_const.jpg"</img> 
</div>

#### Lambda testing events:

CREATE:
```json
{
  "http_method": "POST",
  "CustomerId": "1",
  "FirstName": "Werner",
  "LastName": "Vogels"
}
```

READ:
```json
{
  "http_method": "GET",
  "CustomerId": "1"
}
```

UPDATE_FirstName:
```json
{
  "http_method": "PUT",
  "CustomerId": "1",
  "FirstName": "Jeff"
}
```

UPDATE_LastName:
```json
{
  "http_method": "PUT",
  "CustomerId": "1",
  "LastName": "Bezos"
}
```

UPDATE_ERROR:
```json
{
  "http_method": "PUT",
  "CustomerId": "1"
}
```

DELETE_ERROR:
```json
{
  "http_method": "DELETE",
  "CustomerId": "1"
}
```

#### **Known issue #1**: 
 - **Issue**: 
- **Cause**: 
- **Solution**: 

## Author:

- [@jmanzur](https://github.com/JManzur)

## Documentation:

- [EXAMPLE](URL)