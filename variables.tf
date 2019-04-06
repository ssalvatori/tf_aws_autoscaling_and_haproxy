variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}

# User with RO permission for EC2 (used by haproxy)
variable "ro_access_key" {
  default = ""
}
variable "ro_secret_key" {
  default = ""
}

variable "region" {
  default = "eu-west-1"
}

variable "ec2type" {
  default     = "t2.micro"
  description = "EC2 Instance type"
}

variable "key_name" {
  default     = "stefano_key"
  description = "Custom Key Name"
}

variable "ami_name" {
  default = "ami-6d48500b"
  description = "ami to use"
}

variable "python-server-repository" {
  default = "https://github.com/ssalvatori/python3_simple_server.git"
}
