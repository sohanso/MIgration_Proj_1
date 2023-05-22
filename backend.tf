terraform {
  backend "s3" {
    bucket = "migration-1-tfstate"
    key    = "tfstatefile/terraform.tfstate"
    region = "eu-central-1"
  }
}
