import {
  to = github_repository.repo_settings
  id = var.target_repository
}

import {
  to = github_branch_protection.protect_all_branches
  id = "${var.target_repository}:*"
}

import {
  to = github_actions_repository_permissions.actions_permissions
  id = var.target_repository
}

import {
  to = github_repository_dependabot_security_updates.updates
  id = var.target_repository
}

