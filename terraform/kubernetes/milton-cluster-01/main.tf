terraform {
  cloud {
    organization = "mcfaul-cloud"
    workspaces {
      name = "talos-cluster-01"
    }
  }
  required_version = "~> 1.5"
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.4"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.2"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
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

provider "vsphere" {}

provider "talos" {}

provider "azurerm" {
  features {}
}

provider "helm" {
  kubernetes {
    host = module.talos_cluster.kubeconfig_host

    client_certificate     = base64decode(module.talos_cluster.kubeconfig_client_certificate)
    client_key             = base64decode(module.talos_cluster.kubeconfig_client_key)
    cluster_ca_certificate = base64decode(module.talos_cluster.kubeconfig_ca_certificate)
  }
}

provider "github" {
  owner = "mcfio"
}

provider "flux" {
  kubernetes = {
    host     = module.talos_cluster.kubeconfig_host

    client_certificate     = base64decode(module.talos_cluster.kubeconfig_client_certificate)
    client_key             = base64decode(module.talos_cluster.kubeconfig_client_key)
    cluster_ca_certificate = base64decode(module.talos_cluster.kubeconfig_ca_certificate)
  }
  git = {
    url = "ssh://git@github.com/${module.git-repository.full_name}.git"
    ssh = {
      username    = "git"
      private_key = tls_private_key.flux.private_key_pem
    }
  }
}

locals {
  virtual_machines = {
    node01 = { cpus = 2, memory = 8192, disk_size = 60, machine_type = "controlplane" }
  }
}

module "talos_cluster" {
  source = "github.com/mcfio/terraform-talos-cluster?ref=v0.1.0"

  cluster_parameters = {
    host_subnet        = "192.168.65.0/24"
    pod_subnet         = "10.246.0.0/18"
    service_subnet     = "10.246.64.0/20"
    api_address        = "192.168.65.10"
    api_domain         = "milton.mcf.io"
    api_port           = "6443"
    kubernetes_version = "v1.27.4"
  }
  location        = "milton"
  cluster_name    = "cluster-01"
  cluster_nodes   = local.virtual_machines
  talos_image     = "talos-v1.4.7-vmtoolsd"
  network_vlan_id = 150
}

module "git-repository" {
  source = "./modules/git-repository/"

  repository_name = module.talos_cluster.cluster_name
}

resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "flux" {
  title      = "Flux"
  repository = module.git-repository.name
  key        = tls_private_key.flux.public_key_openssh
  read_only  = false
}

resource "flux_bootstrap_git" "flux" {
  path = "kubernetes"

  depends_on = [
    github_repository_deploy_key.flux
  ]
}

# module "flux-bootstrap" {
#   source = "./modules/flux-bootstrap/"
#
#   kubeconfig_host               = module.talos_cluster.kubeconfig_host
#   kubeconfig_client_certificate = base64decode(module.talos_cluster.kubeconfig_client_certificate)
#   kubeconfig_client_key         = base64decode(module.talos_cluster.kubeconfig_client_key)
#   kubeconfig_ca_certificate     = base64decode(module.talos_cluster.kubeconfig_ca_certificate)
#
#   repository_name      = module.git-repository.name
#   repository_full_name = module.git-repository.full_name
# }
