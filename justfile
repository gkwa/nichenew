set shell := ["bash", "-uc"]

default:
    @just --list

format:
    terraform fmt -recursive .
    just --unstable --fmt

init:
    terraform init

plan:
    terraform plan -out=tfplan

apply:
    terraform apply tfplan

destroy:
    terraform plan -destroy -out=tfplan
    terraform apply tfplan

fmt:
    terraform fmt
