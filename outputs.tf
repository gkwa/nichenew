output "repository_settings" {
  description = "Repository settings configuration"
  value = {
    name = data.github_repository.repo.name
  }
}

output "configured_secrets" {
  value       = keys(local.secrets)
  description = "List of secret names configured from .env file"
  sensitive   = false
}

