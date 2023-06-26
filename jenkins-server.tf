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
