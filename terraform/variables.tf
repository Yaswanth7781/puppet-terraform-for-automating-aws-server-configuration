variable "vpc_id" {
  default = "vpc-080c79b14737cec23"
}

variable "subnet_id" {
  default = "subnet-0427ff2718cef8ef8"
}

variable "ami_id" {
  default = "ami-082a1ff88c78c6290"
}

variable "control_security_group_id" {
  default = "sg-0e09a8fbf83f2831c"
}

variable "instance_type" {
  default = "t3.small"
}

variable "key_name" {
  default = "uniguard-devops-key"
}

variable "public_key_path" {
  default = "../ssh/uniguard_ec2.pub"
}
