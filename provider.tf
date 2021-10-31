# Previous execution of "aws configure" is needed
provider "aws" {
  region  = var.aws_region
  profile = "default"
}