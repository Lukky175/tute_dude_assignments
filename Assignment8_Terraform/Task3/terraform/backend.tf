terraform {
  backend "s3" {
    bucket = "task3-terraform-state-638614235355"
    key    = "task3/terraform.tfstate"
    region = "ap-south-1"
  }
}