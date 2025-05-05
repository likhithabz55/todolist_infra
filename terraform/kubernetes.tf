provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

resource "kubernetes_namespace" "qa" {
  metadata {
    name = "qa"
  }
}

resource "kubernetes_namespace" "uat-blue" {
  metadata {
    name = "uat-blue"
  }
}

resource "kubernetes_namespace" "uat-green" {
  metadata {
    name = "uat-green"
  }
}

resource "kubernetes_namespace" "prod-blue" {
  metadata {
    name = "prod-blue"
  }
}

resource "kubernetes_namespace" "prod_green" {
  metadata {
    name = "prod-green"
  }
}

resource "kubernetes_namespace" "prod" {
  metadata {
    name = "prod"
  }
}