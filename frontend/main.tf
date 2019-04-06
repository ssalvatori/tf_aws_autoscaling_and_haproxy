resource "aws_instance" "frontend" {
  ami           = "${var.ami_name}"
  instance_type = "${var.ec2type}"
  key_name      = "${var.key_name}"

  tags = {
    Name = "frontend"
  }

  vpc_security_group_ids = ["${aws_security_group.frontend.id}"]

  provisioner "local-exec" {
    command = "echo ${aws_instance.frontend.public_ip} >> public_ip_frontend.txt"
  }

  provisioner "file" {
    source      = "${path.module}/config/haproxy-setup.sh"
    destination = "/tmp/haproxy-setup.sh"
  }

  provisioner "file" {
    source      = "${path.module}/config/haproxy-autoscaling-update.rb"
    destination = "/tmp/haproxy-autoscaling-update.rb"
  }

  provisioner "file" {
    source      = "${path.module}/config/cron.sh"
    destination = "/tmp/cron.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo add-apt-repository ppa:vbernat/haproxy-1.6 -y",
      "sudo add-apt-repository ppa:brightbox/ruby-ng -y",
      "sudo apt-get update",
      "sudo apt-get install -y haproxy",
      "echo 'ENABLED=1' | sudo tee --append /etc/default/haproxy",
      "sudo systemctl enable haproxy",
      "sudo service start haproxy",
      "sudo chmod +x /tmp/haproxy-setup.sh",
      "sudo /tmp/haproxy-setup.sh",
      "sudo mv /tmp/haproxy-autoscaling-update.rb /usr/bin/haproxy-autoscaling-update.rb",
      "sudo apt-get install -y software-properties-common ruby2.3 ruby2.3-dev zlib1g-dev libxml2-dev build-essential libpcre3 libpcre3-dev",
      "sudo gem install aws-sdk",
      "sudo chmod +x /tmp/cron.sh",
      "/tmp/cron.sh ${var.ro_access_key} ${var.ro_secret_key} ${var.autoscaling_group} ${var.region}",
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("~/.ssh/id_rsa")}"
  }
}

resource "aws_security_group" "frontend" {
  name = "frontend"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}