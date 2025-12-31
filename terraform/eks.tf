module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.repo_name}-cluster-${var.environment}"
  cluster_version = "1.31"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
    }
  }

#   access_entries = {
#     ml-user = {
#       principal_arn     = "arn:aws:iam::942497601151:user/ml-project-user"
#       kubernetes_groups = []
#       policy_associations = {
#         admin = {
#           policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
#           access_scope = {
#             type = "cluster"
#           }
#         }
#       }
#     }
#   }

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Name        = "${var.repo_name}-eks-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}