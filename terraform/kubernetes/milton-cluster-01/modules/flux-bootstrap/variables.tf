variable "kubeconfig_host" {
  type = string
}

variable "kubeconfig_client_certificate" {
  sensitive = true
  type = string
}

variable "kubeconfig_client_key" {
  sensitive = true
  type = string
}

variable "kubeconfig_ca_certificate" {
  sensitive = true
  type = string
}

# variable "github_token" {
#   sensitive = true
#   type = string
# }

variable "repository_name" {
  type = string
}

variable "repository_full_name" {
  type = string
}
