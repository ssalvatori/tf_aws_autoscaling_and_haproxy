data "aws_availability_zones" "available" {}

/* INSTANCE TO BE USED IN THE AUTOSCALE */
resource "aws_instance" "backend" {
  ami = "${var.ami_name}"

  instance_type               = "${var.ec2type}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = true

  tags = {
    Name      = "backend"
    Terraform = "true"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  vpc_security_group_ids = ["${aws_security_group.backend.id}"]

  /* NGINX configuration */
  provisioner "file" {
    source      = "${path.module}/config/nginx-default.conf"
    destination = "/tmp/nginx-default.conf"
  }

  provisioner "file" {
    source      = "${path.module}/config/nginx.gzip.conf"
    destination = "/tmp/nginx.gzip.conf"
  }

  provisioner "file" {
    source      = "${path.module}/config/python-server.service"
    destination = "/tmp/python-server.service"
  }

  /* NGINX install and setup */
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install nginx nginx-extras -y",
      "sudo mv /tmp/nginx-default.conf /etc/nginx/sites-available/default",
      "sudo mv /tmp/nginx.gzip.conf /etc/nginx/conf.d/gzip.conf",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install git -y",
      "sudo mkdir -p /opt/test",
      "sudo git clone ${var.python-server-repository} /opt/test",
    ]
  }

  /* SystemD configuration file */
  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/python-server.service /etc/systemd/system/python-server.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable python-server.service",
      "sudo systemctl start python-server.service",
    ]
  }
}

# CREATE CUSTOM AMI
resource "aws_ami_from_instance" "backend-ami" {
  name               = "backend-ami"
  source_instance_id = "${aws_instance.backend.id}"
}

/* CONFIGURATION FOR AUTOSCALING */
resource "aws_launch_configuration" "backend_server" {
  name = "backend"

  image_id        = "${aws_ami_from_instance.backend-ami.id}"
  instance_type   = "${var.ec2type}"
  security_groups = ["${aws_security_group.backend.id}"]
  key_name        = "${var.key_name}"

  lifecycle {
    create_before_destroy = true
  }
}

# AUTOSCALING 
resource "aws_autoscaling_group" "backend_autoscaling" {
  name = "backend_group"

  launch_configuration = "${aws_launch_configuration.backend_server.id}"
  availability_zones   = ["${data.aws_availability_zones.available.names}"]
  min_size             = 2
  max_size             = 2
  health_check_type    = "EC2"

  lifecycle {
    create_before_destroy = true
  }
}

# SECURITY GROUP FOR backend servers (80 and 22)
# TODO link this to default VPC
resource "aws_security_group" "backend" {
  name = "backend"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
