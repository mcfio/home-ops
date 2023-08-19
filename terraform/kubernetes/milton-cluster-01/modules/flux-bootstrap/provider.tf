provider "flux" {
  kubernetes = {
    host     = var.kubeconfig_host
    insecure = true

    client_certificate    = var.kubeconfig_client_certificate
    client_key            = var.kubeconfig_client_key
    client_ca_certificate = var.kubeconfig_ca_certificate
  }
  git = {
    url = "ssh://git@github.com/${var.repository_full_name}.git"
    ssh = {
      username    = "git"
      private_key = tls_private_key.flux.private_key_pem
    }
  }
}

provider "github" {
  owner = "mcfio"
}
