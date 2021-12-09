provider "aws" {
        version    = "~> 2.0"
        access_key = var.access_key 
        secret_key = var.secret_key
}

provider "aws" {
    region = "eu-central-1"
}
#
resource "aws_security_group" "EC2SecurityGroup" {
    description = "Expose http only to outside "
    name = "sg-air-tek_prod"
    tags = {
        Name = "air-tek_prod"
    }
#    vpc_id = "vpc-018faaf55f25c8645"
    ingress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        description = "HTTP"
        from_port = 80
        protocol = "tcp"
        to_port = 80
    }
#ADD bastion/jump-host's public IP
#    ingress {
#        cidr_blocks = [
#            "/32"
#        ]
#        description = "SSH access to bastion/jump-host only"
#        from_port = 22
#        protocol = "tcp"
#        to_port = 22
#    }
    egress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 0
        protocol = "tcp"
        to_port = 65535
    }
}
#
resource "aws_instance" "EC2Instance" {
  ami             = "ami-0db9040eb3ab74509" 
  subnet_id       = var.subnet
  key_name        = var.keyName
  availability_zone = "eu-central-1b"
  instance_type = "t3a.medium"
    root_block_device {
        volume_size = 20
        volume_type = "gp2"
        delete_on_termination = true
    }
  monitoring = true
    tags = {
        Name = "air-tek_prod"
        serving-protocols = "http"
    }
  volume_tags = {
    Name = var.instanceName
  }
  provisioner "file" {
    source      = "infra-team-test.zip"
    destination = "/tmp/infra-team-test.zip"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt upgrade -y",
      "sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt-get update -y",
      "sudo apt install docker-ce docker-ce-cli containerd.io -y",
      "sudo curl -L \"https://github.com/docker/compose/releases/download/1.29.1/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "sudo chmod 777 /usr/local/bin/docker-compose",
      "sudo unzip /tmp/infra-team-test.zip -d /tmp/workdir",
      "sudo docker-compose -f /tmp/workdir/infra-team-test/docker-compose.yml up -d"
    ]
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    password    = ""
    private_key = file(var.keyPath)
    host        = self.public_ip
  }
}