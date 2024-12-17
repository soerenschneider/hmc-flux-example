provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-new"
}

resource "kubernetes_secret" "example" {
  metadata {
    name      = "azure-cluster-identity-secret"
    namespace = "hmc-system"
  }

  data = {
    clientSecret = azuread_service_principal_password.capz.value
  }
}
