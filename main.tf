provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

# CUSTOM KEY
resource "aws_key_pair" "custom_key" {
  key_name   = "${var.key_name}"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

module "backend" {
  source = "./backend"

  ec2type  = "${var.ec2type}"
  key_name = "${var.key_name}"
  ami_name = "${var.ami_name}"

  python-server-repository = "${var.python-server-repository}"
}

module "frontend" {
  source = "./frontend"

  ec2type  = "${var.ec2type}"
  key_name = "${var.key_name}"
  ami_name = "${var.ami_name}"

  ro_access_key = "${var.ro_access_key}"
  ro_secret_key = "${var.ro_secret_key}"

  autoscaling_group = "backend_group"
  region = "${var.region}"
}
