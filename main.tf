# main.tf
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

data "github_repository" "repo" {
  name = var.target_repository
}

# Modify repository settings after data lookup
resource "github_repository" "repo_settings" {
  name = data.github_repository.repo.name
  # Keep existing settings from data lookup
  visibility      = data.github_repository.repo.visibility
  has_issues      = data.github_repository.repo.has_issues
  has_discussions = data.github_repository.repo.has_discussions
  has_projects    = data.github_repository.repo.has_projects
  has_wiki        = data.github_repository.repo.has_wiki
  # Enable auto-merge and branch deletion
  allow_auto_merge       = true
  delete_branch_on_merge = true
}

# Single branch protection rule that applies to all branches
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
    strict   = false
    contexts = ["Build & Test (ubuntu-latest)"]
  }
}

resource "github_actions_repository_permissions" "actions_permissions" {
  repository      = var.target_repository
  allowed_actions = "all"
  enabled         = true
}