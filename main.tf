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
