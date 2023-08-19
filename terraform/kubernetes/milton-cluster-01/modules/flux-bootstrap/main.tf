terraform {
  required_version = "~> 1.5"
  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = "~> 1.0"
    }
    github = {
      source  = "integrations/github"
      version = "~>5.18"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# resource "tls_private_key" "flux" {
#   algorithm   = "ECDSA"
#   ecdsa_curve = "P256"
# }
#
# resource "github_repository_deploy_key" "flux" {
#   title      = "Flux"
#   repository = var.repository_name
#   key        = tls_private_key.flux.public_key_openssh
#   read_only   = false
# }
#
# resource "flux_bootstrap_git" "flux" {
#   path = "kubernetes"
#
#   depends_on = [
#     github_repository_deploy_key.flux
#   ]
# }
