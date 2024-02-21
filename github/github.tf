variable "github_org" {
  type = string
}

variable "github_repo" {
  type = string
}

resource "teleport_provision_token" "github_actions" {
  version = "v2"
  metadata = {
    name        = "github-actions-bot"
    description = "Token for GitHub Actions bot for CI Terraform runs"
  }

  spec = {
    roles = ["Bot"]
    bot_name = "github-actions"
    join_method = "github"
    github: {
      allow: [
        {
          "repository": "${var.github_org}/${var.github_repo}"
        }
      ]
    }
  }
}

resource "teleport_bot" "github_actions" {
  name = "github-actions"
  token_id = teleport_provision_token.github_actions.metadata.name
  roles = ["terraform"]
}
