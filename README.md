# Provider.TF Start
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    jenkins_x = {
      source  = "jenkins-x/eks-jx/aws"
      version = "~> 1.21.3"
    }
  }
}

module "jenkins_x" {
  source  = "jenkins-x/eks-jx/aws"
  version = "~> 1.21.3"

  cluster_name = "my-jenkinsx-cluster"
  cluster_version = "1.27"  # Replace with your desired EKS version

  # Customize additional module input variables as per your requirements
  # Refer to the module documentation for available options
}
provider "aws" {
  region  = "us-east-1"
  profile = "hendrixz"

}
#Provider.TF END

#Main.TF START
# main.tf
# Create the VPC
resource "aws_vpc" "jurassic_vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Create a subnet within the VPC
resource "aws_subnet" "jurassic_subnet" {
  vpc_id                  = aws_vpc.jurassic_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"  
}

# Create an internet gateway
resource "aws_internet_gateway" "jurassic_gateway" {
  vpc_id = aws_vpc.jurassic_vpc.id
}

# Attach the internet gateway to the VPC
resource "aws_vpc_attachment" "jurassic_attachment" {
  vpc_id             = aws_vpc.jurassic_vpc.id
  internet_gateway_id = aws_internet_gateway.jurassic_gateway.id
}

# Create a route table
resource "aws_route_table" "jurassic_route_table" {
  vpc_id = aws_vpc.jurassic_vpc.id
}

# Associate the route table with the subnet
resource "aws_route_table_association" "jurassic_association" {
  subnet_id      = aws_subnet.jurassic_subnet.id
  route_table_id = aws_route_table.jurassic_route_table.id
}

# Create a route to the internet
resource "aws_route" "jurassic_route" {
  route_table_id         = aws_route_table.jurassic_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.jurassic_gateway.id
}

# Create the EKS cluster
resource "aws_eks_cluster" "jurassic_cluster" {
  name     = "jurassic-eks-cluster"
  role_arn = aws_iam_role.jurassic_eks_role.arn
  version  = "1.27"  

  vpc_config {
    subnet_ids         = [aws_subnet.jurassic_subnet.id]
    security_group_ids = [aws_security_group.jurassic_sg.id]
  }
}

# Create the EKS node group
resource "aws_eks_node_group" "jurassic_node_group" {
  cluster_name    = aws_eks_cluster.jurassic_cluster.name
  node_group_name = "jurassic-node-group"
  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 5
  }
  subnet_ids = [aws_subnet.jurassic_subnet.id]
}

# Create the Jenkins infrastructure pipeline
resource "jenkins_pipeline" "jurassic_infra_pipeline" {
  name       = "jurassic-infra-pipeline"
  repository = "https://github.com/paulouma5/infastructutre_repo"  
  // Define the remaining Jenkins pipeline configuration here
}

# Create the Jenkins application pipeline
resource "jenkins_pipeline" "jurassic_app_pipeline" {
  name       = "jurassic-app-pipeline"
  repository = "https://github.com/paulouma5/application_repo"  
  // Define the remaining Jenkins pipeline configuration here
}
#Main.TF END

#Jenkins-server.TF START
# jenkins-server.tf

resource "aws_instance" "jenkins_server" {
  ami           = "ami-053b0d53c279acc90"  
  instance_type = "t3.medium"  # Or your preferred instance type

  key_name      = "hendrixz"  # Replace with your key pair name
  security_group_ids = [aws_security_group.jenkins_sg.id]

  # Other necessary configuration options like VPC subnet, IAM role, etc.
  # Add the required tags, e.g., Name, Environment, etc.
depends_on = [aws_internet_gateway.jurassic_gateway]
  # Provisioner block to execute remote commands after instance creation
  provisioner "remote-exec" {
    inline = [
      # Example: Install required software on the Jenkins server
      "sudo apt-get update",
      "sudo apt-get install -y <package>",
    "sudo apt upgrade -y",
    "sudo apt install -y openjdk-11-jdk",
    "sudo apt install -y apt-transport-https ca-certificates curl software-properties-common",
    "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
    "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable'",
    "sudo apt update",
    "sudo apt install -y docker-ce",
    "sudo usermod -aG docker ubuntu",
    "sudo apt install -y awscli",
    "sudo apt install -y git",
    "wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add - ",
    "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
    "sudo apt update",
    "sudo apt install -y jenkins",
    "sudo systemctl start jenkins",
    "sudo systemctl enable jenkins"
    ]
  }
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Security group for Jenkins server"

  # Add necessary ingress and egress rules to allow required traffic
  # For example, allow SSH (port 22), HTTP (port 80), HTTPS (port 443), etc.
}
#Jenskins-server.TF END
