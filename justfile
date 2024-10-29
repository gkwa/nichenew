set shell := ["bash", "-uc"]

default:
    @just --list

fmt:
    terraform fmt -recursive .
    just --unstable --fmt

init:
    terraform init

import repo org:
    terraform import \
        -var="repository_owner={{ org }}" \
        -var="target_repository={{ repo }}" \
        github_repository.repo_settings {{ repo }}

plan repo org:
    terraform plan -out=tfplan \
        -var="repository_owner={{ org }}" \
        -var="target_repository={{ repo }}"

apply:
    terraform apply tfplan

destroy repo org:
    terraform plan -destroy -out=tfplan \
        -var="repository_owner={{ org }}" \
        -var="target_repository={{ repo }}"
    terraform apply tfplan

setup repo org:
    just init
    just import {{ repo }} {{ org }}
    just plan {{ repo }} {{ org }}
    just apply
