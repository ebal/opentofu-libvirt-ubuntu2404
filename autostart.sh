#!/bin/bash

if tofu status >/dev/null 2>&1; then
    echo "Tofu already initialized."
else
    echo "Initializing Tofu..."
    tofu init
fi

tofu fmt -recursive

tofu validate

# Optional: load config file with variables (secrets or API keys)
if [ -f tofu.config ]; then
    source tofu.config
fi

# Only apply if plan succeeds
tofu plan -out tofu.out && tofu apply -auto-approve tofu.out
