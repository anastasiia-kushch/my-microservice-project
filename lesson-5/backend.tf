terraform {
  backend "s3" {
    bucket         = "anastasiia-kushch-tf-state-2026" # Должно совпадать с bucket_name в main.tf
    key            = "lesson-5/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
