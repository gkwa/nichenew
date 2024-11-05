set shell := ["bash", "-uc"]

# Default repository owner from terraform.tfvars

default_owner := "gkwa"

default:
    @just --list

fmt:
    terraform fmt -recursive .
    just --unstable --fmt

init:
    terraform init

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
    just plan {{ repo }} {{ org }}
    just apply
