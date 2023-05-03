terraform {
  backend "s3" {
    bucket  = "grow-room-backend"
    encrypt = true
    key     = "terraform.tfstate"
    region  = "us-west-2"
    profile = "architect"
  }

}

provider "aws" {
  region = "us-west-2"
}