#!/bin/bash
set -e

echo "Destroying Terraform resources..."
terraform destroy -auto-approve

echo "Cleaning up deployment packages in bin folder..."
rm -f ./bin/openai_python_layer.zip
rm -f ./bin/openai_get_api_key.zip
rm -f ./bin/lambdagpt_invoke_api.zip

echo "Script completed successfully."
