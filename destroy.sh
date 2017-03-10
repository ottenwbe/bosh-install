#!/usr/bin/env bash

ssh -i insecure-deployer ubuntu@$(terraform output bosh_dns) date