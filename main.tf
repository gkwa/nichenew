terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.3.1"
    }
  }
}

provider "github" {
  owner = var.repository_owner
}

data "github_repository" "repo" {
  name = var.target_repository
}

data "github_branch" "default" {
  repository = data.github_repository.repo.name
  branch     = data.github_repository.repo.default_branch
}

locals {
  env_file = file("${path.module}/.env")
  secrets = {
    for line in split("\n", local.env_file) :
    split("=", line)[0] => split("=", line)[1]
    if length(split("=", line)) == 2
  }
}

# Repository settings including security features
resource "github_repository" "repo_settings" {
  name = data.github_repository.repo.name

  visibility      = data.github_repository.repo.visibility
  has_issues      = data.github_repository.repo.has_issues
  has_discussions = data.github_repository.repo.has_discussions
  has_projects    = data.github_repository.repo.has_projects
  has_wiki        = data.github_repository.repo.has_wiki

  # Enable auto-merge
  allow_auto_merge       = true
  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = true
  delete_branch_on_merge = true

  vulnerability_alerts = true

  security_and_analysis {
    secret_scanning {
      status = "enabled"
    }
    secret_scanning_push_protection {
      status = "enabled"
    }
  }
}

# Dependabot security updates
resource "github_repository_dependabot_security_updates" "updates" {
  repository = data.github_repository.repo.name
  enabled    = true

  depends_on = [
    github_repository.repo_settings,
  ]
}

# Branch protection with minimal requirements to allow auto-merge
resource "github_branch_protection" "protect_all_branches" {
  repository_id                   = data.github_repository.repo.name
  pattern                         = "*"
  enforce_admins                  = false
  required_linear_history         = false
  require_signed_commits          = false
  require_conversation_resolution = false
  allows_deletions                = true
  allows_force_pushes             = true

  required_status_checks {
    strict = false
    contexts = [
      "Build & Test (ubuntu-latest)",
      "Build & Test (windows-latest)",
      "Build & Test (macOS-latest)"
    ]
  }

  # If the import fails (because protection doesn't exist), this resource will be ignored
  lifecycle {
    ignore_changes = all
  }
}

# GitHub Actions permissions
resource "github_actions_repository_permissions" "actions_permissions" {
  repository      = var.target_repository
  allowed_actions = "all"
  enabled         = true
}

# Secrets from .env file
resource "github_actions_secret" "repository_secrets" {
  for_each = local.secrets

  repository      = github_repository.repo_settings.name
  secret_name     = each.key
  plaintext_value = each.value
}

