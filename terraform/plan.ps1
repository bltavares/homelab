#!/usr/bin/env bash

terraform plan --var-file ../secrets/production.tfvars --out terraform.plan
