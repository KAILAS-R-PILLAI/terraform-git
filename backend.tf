terraform {
  backend "s3" {
    bucket         = "kailas-terraform-state-prod"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}