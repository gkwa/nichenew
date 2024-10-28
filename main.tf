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
  repository_name    = basename(path.cwd)
  protected_branches = ["main", "master"]
}

data "github_repository" "repo" {
  name = local.repository_name
}

resource "github_repository" "repo" {
  name                   = local.repository_name
  auto_init              = true
  allow_auto_merge       = true
  delete_branch_on_merge = true
  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = true
  visibility             = "public"
  has_issues             = true
  has_projects           = true
  has_wiki               = true
  archived               = false
}

resource "github_branch_protection" "protect_branches" {
  for_each = toset(local.protected_branches)

  repository_id = github_repository.repo.node_id
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
  repository      = github_repository.repo.name
  allowed_actions = "all"
  enabled         = true
}
