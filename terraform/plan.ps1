#!/usr/bin/env bash

terraform.exe plan --var-file ../secrets/production.tfvars --out terraform.plan
