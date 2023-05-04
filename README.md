To set up in AWS, first clone the repo:

`git clone git@github.com:DaedalusHub/LambdaGPT.git`

For automated install, use the `install.sh` helper script from the LambdaGPT directory:

```
cd LambdaGPT/
sh .install.sh
```

If the script completes successfully, you can test the API with the curl command below:

```
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-3.5",
    "messages": [
      {
        "role": "user",
        "content": "How are you?"
      }
    ]
}' \
"<API_GATEWAY_INVOKE_URL>"
```

To deploy manually, make sure to have the following files in your working directory before running Terraform, :

1. openai_python_layer.zip - The zip file containing the openai library as a Lambda Layer.
2. openai_get_api_key.zip - The zip file containing the Python script for the openai_get_api_key Lambda function.
3. lambdagpt_invoke_api.zip - The zip file containing the lambda_function.py script above for the lambdagpt_invoke_api Lambda function.

To deploy the resources, follow these steps:

1. Run terraform init to initialize the Terraform working directory.
2. Run terraform apply to create the resources defined in main.tf. Confirm the changes by typing yes when prompted.
3. After the resources are created, the API Gateway URL will be displayed as an output. You can use this URL to make API calls to the lambdagpt_invoke_api Lambda function.

Please note that you'll need to replace <OPENAI_API_KEY> in terraform.tfvars with your actual OpenAI API key, and the ARN in the get_api_key function should be replaced with the actual ARN of the openai_get_api_key Lambda function in your AWS account. Other variables should be set in tfvars depending on user settings.