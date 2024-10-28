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
  repository_name = basename(path.cwd)
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

