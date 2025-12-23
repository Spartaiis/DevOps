terraform {
  backend "s3" {
    # Remote S3 bucket used for Terraform state
    bucket         = "fundamentals-of-devops-tofu-state"
    key            = "ch5/tofu/live/lambda-sample"       
    region         = "us-east-2"
    encrypt        = true
    # DynamoDB table used for state locking
    dynamodb_table = "fundamentals-of-devops-tofu-state"
  }
}