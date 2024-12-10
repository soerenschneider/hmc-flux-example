provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-kind"
}

resource "kubernetes_secret" "example" {
  metadata {
    name = "aws-cluster-identity-secret"
    namespace = "hmc-system"
  }

  data = {
    AccessKeyID = aws_iam_access_key.cluster_api_user_keys.id
    SecretAccessKey = aws_iam_access_key.cluster_api_user_keys.secret
  }
}
