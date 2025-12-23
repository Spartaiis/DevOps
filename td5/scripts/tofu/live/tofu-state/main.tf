provider "aws" {
  region = "us-east-2"
}

module "state" {
  source = "github.com/brikis98/devops-book//ch5/tofu/modules/state-bucket"

  # Name of the S3 bucket to create/use for Terraform remote state
  name = "fundamentals-of-devops-tofu-state"
}