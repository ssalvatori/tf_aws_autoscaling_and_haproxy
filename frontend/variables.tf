variable "ec2type" {
  description = "EC2 Instance type"
}

variable "ami_name" {
  description = "AMI to use"
}

variable "key_name" {
  description = "Custom Key Name, File must be store in ~/.aws/credentials/<key_name>.pem"
}

variable "ro_access_key" {
  description = "RO access key"
}
variable "ro_secret_key" {
  description = "RO secret key"
}

variable "autoscaling_group" {
  description = "Autoscaling group to check"
}

variable "region" {
  description = "aws region"
}
