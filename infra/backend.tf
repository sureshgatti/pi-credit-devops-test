terraform {
  backend "s3" {
    bucket         = "pi-credit-terraform-state-015800952701-eu-north-1"
    key            = "pi-credit/${terraform.workspace}/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "pi-credit-terraform-locks"
    encrypt        = true
  }
}
