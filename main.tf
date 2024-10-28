terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">=6.3.1"
    }
  }
}

provider "github" {
  owner = var.repository_owner
}

locals {
  protected_branches = ["main", "master"]
}

data "github_repository" "repo" {
  name = var.target_repository
}

resource "github_branch_protection" "protect_branches" {
  for_each = toset(local.protected_branches)

  repository_id = data.github_repository.repo.name
  pattern       = each.value

  enforce_admins                  = false
  required_linear_history         = false
  require_signed_commits          = false
  require_conversation_resolution = false
  allows_deletions                = true
  allows_force_pushes             = true

  required_status_checks {
    strict   = false
    contexts = ["Build & Test (ubuntu-latest)"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = false
    require_code_owner_reviews      = false
    required_approving_review_count = 0
  }
}

resource "github_actions_repository_permissions" "actions_permissions" {
  repository      = var.target_repository
  allowed_actions = "all"
  enabled         = true
}
