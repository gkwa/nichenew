output "repository_settings" {
  description = "Repository settings configuration"
  value = {
    name                  = github_repository.repo.name
    auto_merge_enabled    = github_repository.repo.allow_auto_merge
    delete_branch_enabled = github_repository.repo.delete_branch_on_merge
  }
}

