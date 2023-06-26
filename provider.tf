terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
   jenkins = {
      source = "taiidani/jenkins"
      version = "0.10.1"
      
    }
  }
}
provider "jenkins" {
  server_url = "127.0.0.1:8080"  # Or use JENKINS_URL env var
  username   = "admin"            # Or use JENKINS_USERNAME env var
  password   = "password"            # Or use JENKINS_PASSWORD env var

}
provider "aws" {
  region  = "us-east-1"
  profile = "hendrixz"

}
