variable "teleport_addr" {
  type = string
}

variable "kubernetes_config_path" {
  type = string
  default = "~/.kube/config"
}

variable "kubernetes_context" {
  type = string
}

variable "identity_file_path" {
  type = string
  default = "/opt/machine-id/identity"
}

variable "jwks" {
  type = string
}