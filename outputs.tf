output "repository_settings" {
  description = "Repository settings configuration"
  value = {
    name = data.github_repository.repo.name
  }
}

