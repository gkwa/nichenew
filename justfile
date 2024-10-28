set shell := ["bash", "-uc"]

default:
    @just --list

format:
    terraform fmt -recursive .
    just --unstable --fmt

init:
    terraform init

plan repo:
    terraform plan -out=tfplan -var="target_repository={{ repo }}"

apply:
    terraform apply tfplan

destroy repo:
    terraform plan -destroy -out=tfplan -var="target_repository={{ repo }}"
    terraform apply tfplan

fmt:
    terraform fmt
