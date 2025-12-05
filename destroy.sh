#!/bin/bash

# Optional: load config file with variables (secrets or API keys)
if [ -f tofu.config ]; then
    source tofu.config
fi

tofu destroy -auto-approve

if [ $? -ne 0 ]; then
    echo "Tofu destroy failed."
    exit 1
else
    rm -rf .terraform*
    rm -f tofu.out
    rm -f terraform.tfstate*
fi

