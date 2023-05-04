#!/bin/bash
set -e

# Install OpenAI package and create the Lambda layer
echo "Creating OpenAI Python layer..."
pip install openai --target python/
pip install --upgrade --force-reinstall -v "urllib3<2" --target python/
zip -r openai_python_layer.zip python/

# Create Lambda function deployment packages
echo "Creating Lambda deployment packages..."
zip -r -j openai_get_api_key.zip src/get_api_key.py
zip -r -j lambdagpt_invoke_api.zip src/invoke_api.py

# Initialize Terraform
echo "Initializing ..."
terraform init || echo "\"terraform init\" failed"

# Apply Terraform changes
echo "Applying Terraform changes..."
terraform apply -auto-approve

# Move deployment packages to bin folder
echo "Moving deployment packages to bin folder..."
mkdir -p bin
mv openai_python_layer.zip ./bin
mv openai_get_api_key.zip ./bin
mv lambdagpt_invoke_api.zip ./bin

# Clean up
echo "Cleaning up..."
rm -r python/

echo "Script completed successfully."
