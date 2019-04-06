variable "ec2type" {
  description = "EC2 Instance type"
}

variable "ami_name" {
  description = "AMI to use"
}

variable "key_name" {
  description = "Custom Key Name, File must be store in ~/.aws/credentials/<key_name>.pem"
}

variable "python-server-repository" {
  description = "git repository with source code"
}