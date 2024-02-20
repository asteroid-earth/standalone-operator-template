variable "github_org" {
  type = string
}

# resource "teleport_provision_token" "github_actions" {
#   version = "v2"
#   metadata = {
#     name        = "github-actions-bot"
#     description = "Token for GitHub Actions bot for CI Terraform runs"
#   }

#   spec = {
#     roles = ["Bot"]
#     bot_name = "github-actions"
#     join_method = "github"
#     github: {
#       allow: [
#         {
#           "repository_owner": var.github_org
#         }
#       ]
#     }
#   }
# }

# resource "teleport_bot" "github_actions" {
#   name = "github-actions"
#   token_id = teleport_provision_token.github_actions.metadata.name
#   roles = ["terraform"]
# }
