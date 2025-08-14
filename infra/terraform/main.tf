# ---------------- VPC ----------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.7"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    "Project" = var.project_name
  }
}

data "aws_availability_zones" "available" {}

# ---------------- EKS ----------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24"

  cluster_name    = "${var.project_name}-cluster"
  cluster_version = var.eks_cluster_version

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      min_size       = var.min_size
      max_size       = var.max_size
      desired_size   = var.desired_size
      instance_types = var.instance_types
      capacity_type  = "ON_DEMAND"

      tags = {
        "Project" = var.project_name
      }
    }
  }

  tags = {
    "Project" = var.project_name
  }
}

# ---------------- ECR ----------------
resource "aws_ecr_repository" "app" {
  name                 = var.project_name
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
  tags = {
    "Project" = var.project_name
  }
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "region" {
  value = var.aws_region
}

output "ecr_repo_url" {
  value = aws_ecr_repository.app.repository_url
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --region=${var.aws_region} --name=${module.eks.cluster_name}"
}
