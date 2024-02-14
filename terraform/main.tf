terraform {
  required_providers {
    teleport = {
      source  = "terraform.releases.teleport.dev/gravitational/teleport"
      version = "~> 15.0"
    }
  }
}

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

provider "teleport" {
  # Update addr to point to your Teleport Cloud tenant URL's host:port

  # make these and the other provider configs variables
  addr               = "${var.teleport_addr}:443"
  identity_file_path = var.identity_file_path
}

provider "kubernetes" {
  config_path = var.kubernetes_config_path
  config_context = var.kubernetes_context
}

provider "helm" {
  kubernetes {
    config_path = var.kubernetes_config_path
    config_context = var.kubernetes_context
  }
}

resource "teleport_role" "k8s_operator" {
  version = "v7"
  metadata = {
    name        = "operator"
    description = "Kubernetes Operator"
  }

  spec = {
    allow = {
      rules = [
        {
          resources = ["*"]
          verbs     = ["delete"]
        },
        {
          resources = ["user"]
          verbs = ["list", "create", "read", "update", "delete"]
        },
        {
          resources = ["auth_connector"]
          verbs = ["list", "create", "read", "update", "delete"]
        },
        {
          resources = ["login_rule"]
          verbs = ["list", "create", "read", "update", "delete"]
        },
        {
          resources = ["token"]
          verbs = ["list", "create", "read", "update", "delete"]
        },
        {
          resources = ["okta_import_rule"]
          verbs = ["list", "create", "read", "update", "delete"]
        },
        {
          resources = ["access_list"]
          verbs = ["list", "create", "read", "update", "delete"]
        },
      ]
    }

    deny = {}
  }
}

resource "teleport_provision_token" "k8s_operator" {
  version = "v2"
  metadata = {
    name        = "operator-bot"
    description = "Token for Kubernetes Operator"
  }

  spec = {
    roles = ["Bot"]
    bot_name = "operator"
    join_method = "kubernetes"
    kubernetes = {
      type: "static_jwks"
      static_jwks = {
        jwks: "{\"keys\":[{\"use\":\"sig\",\"kty\":\"RSA\",\"kid\":\"r0m_dfAndxaO-SyTgXILGIOFpvW5leFlVuwelMFDHAU\",\"alg\":\"RS256\",\"n\":\"pi2V72xEwm8Hja_kq_yqEZtAlhye2--hoMBfod_cFdER5VNfpkjR3dbTYBDoD46hiHJUSYC2ItVnfW3IuJkZyPVBXfdr5hUrqM1gE9HIf6siqTHwV9yHWHJ6Ac2K7DyCEaSzkFG-_jzpU3CNyn7AoE71_5DOFcbzUb7-y-3PdgLC_q7-JbLfa-qdc9YbNeN8QuMzsZLNKMUIx1LhA-Huplp5yoi7Sw9o4DhnvwMiqHSQfi9ulEZpl3bxxGOMtlwdLe59NG6dd3fyXk3HrTacE3bnMhhzD815Jx9n-fXugPRF_7AM71IoL1EGcCKDQp3djIH_hQD775SDCf-Ur5HtDQ\",\"e\":\"AQAB\"}]}"
      }
      allow = [
        {
          service_account = "teleport-iac:teleport-k8s-operator-teleport-operator"
        }
      ]
    }
  }
}

resource "teleport_bot" "operator" {
  name = "operator"
  token_id = teleport_provision_token.k8s_operator.metadata.name
  roles = ["operator"]
}

resource "kubernetes_namespace" "teleport-iac" {
  metadata {
    name = "teleport-iac"
  }
}

resource "helm_release" "teleport-k8s-operator" {
  name = "teleport-k8s-operator"

  repository = "https://charts.releases.teleport.dev"
  chart = "teleport-operator"
  version = "15.0.1"

  namespace = kubernetes_namespace.teleport-iac.metadata[0].name

  set {
    name = "teleportAddress"
    value = "${var.teleport_addr}:443"
    type = "string"
  }

  set {
    name = "teleportClusterName"
    value = var.teleport_addr
    type = "string"
  }

  set {
    name = "token"
    value = "operator-bot"
    type = "string"  
  }

  depends_on = [teleport_provision_token.k8s_operator, teleport_bot.operator]
}