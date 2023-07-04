terraform {
  cloud {
    organization = "mcfaul-cloud"
    workspaces {
      name = "vsphere-talos"
    }
  }
  required_version = "~> 1.5"
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.0"
    }
  }
}

resource "vsphere_tag_category" "talos" {
  name        = "talos"
  description = "Attributes associated with Talos Kubernetes Clusters"
  cardinality = "MULTIPLE"

  associable_types = [
    "VirtualMachine"
  ]
}

resource "vsphere_tag" "controlplane" {
  name        = "controlplane"
  category_id = vsphere_tag_category.talos.id
  description = "talos control plane machine_type"
}

resource "vsphere_tag" "worker" {
  name        = "worker"
  category_id = vsphere_tag_category.talos.id
  description = "talos worker machine_type"
}

data "vsphere_content_library" "os_images" {
  name = "os-images"
}

# When a new release is created, duplicate this section of code increasing the semver appropriately
# When no longer needing the library item, remove it.
resource "vsphere_content_library_item" "talos_image_v1_4_6" {
  name       = "talos-v1.4.6"
  file_url   = "https://github.com/siderolabs/talos/releases/download/v1.4.6/vmware-amd64.ova"
  library_id = data.vsphere_content_library.os_images.id
}

# vSphere Content Libraries are pretty limiting in that, there's no way to link latest releases
# this limitation exgtends to the terraform provider, at 89MB per image, not too concerned.
resource "vsphere_content_library_item" "talos_image_latest" {
  name       = "talos-latest"
  file_url   = "https://github.com/siderolabs/talos/releases/download/v1.4.6/vmware-amd64.ova"
  library_id = data.vsphere_content_library.os_images.id
}
