terraform {
  cloud {
    organization = "mcfaul-cloud"
    workspaces {
      name = "vsphere-talos"
    }
  }
}

locals {
  managed_versions = toset([
    "v1.4.6",
    "v1.4.7",
  ])
  managed_tags = toset([
    "controlplane",
    "worker",
  ])
}

resource "vsphere_tag_category" "talos" {
  name        = "talos"
  description = "Attributes associated with Talos Kubernetes Clusters"
  cardinality = "MULTIPLE"

  associable_types = [
    "VirtualMachine"
  ]
}

resource "vsphere_tag" "talos" {
  for_each    = local.managed_tags
  name        = each.key
  category_id = vsphere_tag_category.talos.id
  description = "talos machine_type='${each.key}'"
}

data "vsphere_content_library" "os_images" {
  name = "os-images"
}

resource "vsphere_content_library_item" "talos" {
  for_each   = local.managed_versions
  name       = "talos-${each.key}"
  file_url   = "https://github.com/siderolabs/talos/releases/download/${each.key}/vmware-amd64.ova"
  library_id = data.vsphere_content_library.os_images.id
}

# vSphere Content Libraries are pretty limiting in that, there's no way to link latest releases
# this limitation exgtends to the terraform provider, at 89MB per image, not too concerned.
resource "vsphere_content_library_item" "talos_image_latest" {
  name       = "talos-latest"
  file_url   = "https://github.com/siderolabs/talos/releases/download/v1.4.7/vmware-amd64.ova"
  library_id = data.vsphere_content_library.os_images.id
}
