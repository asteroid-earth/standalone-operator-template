variable "operator_bot_name" {
  type = string
  default = "operator"
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
    bot_name = var.operator_bot_name
    join_method = "kubernetes"
    kubernetes = {
      type: "static_jwks"
      static_jwks = {
        jwks: var.jwks
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
  name = var.operator_bot_name
  token_id = teleport_provision_token.k8s_operator.metadata.name
  roles = [teleport_role.k8s_operator.metadata.name]
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