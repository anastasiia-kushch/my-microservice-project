terraform {
  backend "s3" {
    bucket         = "anastasiia-kushch-tf-state-2026"
    key            = "lesson-7/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
