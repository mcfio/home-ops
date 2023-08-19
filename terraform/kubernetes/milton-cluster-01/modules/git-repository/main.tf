terraform {
  required_version = "~> 1.5"
  required_providers {
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

resource "github_repository" "gitops_repo" {
  name = var.repository_name

  auto_init = true
}
