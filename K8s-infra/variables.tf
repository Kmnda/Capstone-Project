
variable "public_key" {
  description = "The public key to use for the EC2 instances."
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy to."
  default     = "ap-southeast-2"
}

variable "instance_type" {
  description = "The EC2 instance type to use."
  default     = "t2.medium"
}
