variable "project_name" {
  type        = string
  default     = "eks-flask-app"
  description = "Project name prefix."
}

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region."
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR block."
}

variable "eks_cluster_version" {
  type        = string
  default     = "1.29"
  description = "EKS Kubernetes version."
}

variable "desired_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 3
}

variable "min_size" {
  type    = number
  default = 2
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}
