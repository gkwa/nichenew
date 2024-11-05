set shell := ["bash", "-uc"]

default:
    @just --list

fmt:
    terraform fmt -recursive .
    just --unstable --fmt

init:
    terraform init

import repo org="": init
    #!/usr/bin/env bash
    set +e  # Continue on errors
    
    # Function to attempt import of a resource
    import_resource() {
        local resource=$1
        local id=$2
        echo "Attempting to import ${resource}..."
        terraform import ${resource} ${id} || echo "Import failed for ${resource} - resource may not exist yet"
    }
    
    if [ -z "{{ org }}" ]; then
        terraform plan \
            -var="target_repository={{ repo }}" \
            -generate-config-out=generated_resources.tf
            
        # Try importing each resource individually
        import_resource "github_repository.repo_settings" "{{ repo }}"
        import_resource "github_repository_dependabot_security_updates.updates" "{{ repo }}"
        import_resource "github_actions_repository_permissions.actions_permissions" "{{ repo }}"
        import_resource "github_branch_protection.protect_all_branches" "{{ repo }}:*"
    else
        terraform plan \
            -var="repository_owner={{ org }}" \
            -var="target_repository={{ repo }}" \
            -generate-config-out=generated_resources.tf
            
        # Try importing each resource individually
        import_resource "github_repository.repo_settings" "{{ repo }}"
        import_resource "github_repository_dependabot_security_updates.updates" "{{ repo }}"
        import_resource "github_actions_repository_permissions.actions_permissions" "{{ repo }}"
        import_resource "github_branch_protection.protect_all_branches" "{{ repo }}:*"
    fi
    
    set -e  # Restore error handling

plan repo org="": init
    #!/usr/bin/env bash
    if [ -z "{{ org }}" ]; then
        terraform plan -out=tfplan \
            -var="target_repository={{ repo }}"
    else
        terraform plan -out=tfplan \
            -var="repository_owner={{ org }}" \
            -var="target_repository={{ repo }}"
    fi

apply:
    terraform apply tfplan

destroy repo org="":
    #!/usr/bin/env bash
    if [ -z "{{ org }}" ]; then
        terraform plan -destroy -out=tfplan \
            -var="target_repository={{ repo }}"
    else
        terraform plan -destroy -out=tfplan \
            -var="repository_owner={{ org }}" \
            -var="target_repository={{ repo }}"
    fi
    terraform apply tfplan

setup repo org="":
    just init
    just import {{ repo }} {{ org }}
    just plan {{ repo }} {{ org }}
    just apply