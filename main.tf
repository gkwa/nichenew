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

data "github_branch" "default" {
  repository = data.github_repository.repo.name
  branch     = data.github_repository.repo.default_branch
}

# Repository settings including security features
resource "github_repository" "repo_settings" {
  name = data.github_repository.repo.name

  visibility      = data.github_repository.repo.visibility
  has_issues      = data.github_repository.repo.has_issues
  has_discussions = data.github_repository.repo.has_discussions
  has_projects    = data.github_repository.repo.has_projects
  has_wiki        = data.github_repository.repo.has_wiki

  allow_auto_merge       = true
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

# Create dependabot.yml file in the repository
# main.tf unchanged except for dependabot_config content
resource "github_repository_file" "dependabot_config" {
  repository          = data.github_repository.repo.name
  branch              = data.github_repository.repo.default_branch
  file                = ".github/dependabot.yml"
  content             = <<-EOT
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    groups:
      all-dependencies:
        patterns:
          - "*"
    open-pull-requests-limit: 10
    auto-merge: true # Enable auto-merge
    auto-merge-conditions:
      - "status-success=Build & Test (ubuntu-latest)"
  
  - package-ecosystem: "gomod"
    directory: "/"
    schedule:
      interval: "weekly"
    groups:
      all-dependencies:
        patterns:
          - "*"
    open-pull-requests-limit: 10
    auto-merge: true # Enable auto-merge
    auto-merge-conditions:
      - "status-success=Build & Test (ubuntu-latest)"
EOT
  commit_message      = "Add Dependabot configuration with auto-merge"
  overwrite_on_create = true

  depends_on = [
    github_repository.repo_settings,
    data.github_branch.default
  ]
}


# Dependabot security updates
resource "github_repository_dependabot_security_updates" "updates" {
  repository = data.github_repository.repo.name
  enabled    = true

  depends_on = [
    github_repository.repo_settings,
    github_repository_file.dependabot_config
  ]
}

# Branch protection with only status checks, no PR approvals
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

# GitHub Actions permissions
resource "github_actions_repository_permissions" "actions_permissions" {
  repository      = var.target_repository
  allowed_actions = "all"
  enabled         = true
}