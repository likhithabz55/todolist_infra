provider "aws" {
  region = var.region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  token = var.aws_session_token
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name                 = "eks-blue-green"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.project_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.project_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.project_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "rds-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "rds-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Allow access to RDS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block] # Allow from internal VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

resource "aws_db_instance" "postgres" {
  identifier             = "app-postgres-db"
  engine                 = "postgres"
  engine_version         = "15.12"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  username               = var.db_username
  password               = var.db_password
  publicly_accessible    = false
  skip_final_snapshot    = true
  db_name                = var.db_name
}

/*output "rds_endpoint" {
  value = "${aws_db_instance.postgres.endpoint}"
}*/

//eks cluster
resource "aws_eks_cluster" "eks_terraform" {
  name     = var.project_name
  version = "1.31"
  //create_iam_role = false
  role_arn = "arn:aws:iam::822298509516:role/LabRole"
  vpc_config {
    subnet_ids = module.vpc.private_subnets
  }
}

resource "aws_eks_node_group" "my_arm64_node_group" {
  cluster_name    = aws_eks_cluster.eks_terraform.name
  node_group_name = "arm64-node-group"
  node_role_arn   = "arn:aws:iam::822298509516:role/LabRole"
  subnet_ids = module.vpc.private_subnets
  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }
  disk_size = 20
  instance_types = ["t4g.small"]
  ami_type       = "AL2_ARM_64" 
  capacity_type = "ON_DEMAND"

  labels = {
    "arch" = "arm64"
  }

  tags = {
    "Name" = "arm64-node-group"
  }
}

data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.eks_terraform.name
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.eks_terraform.name
}

