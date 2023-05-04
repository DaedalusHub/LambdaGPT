# LambdaGPT - A Serverless GPT Implementation on AWS #

LambdaGPT is a serverless implementation of OpenAI's ChatGPT models using AWS Lambda and API Gateway. This project allows you to deploy and run the GPT model on AWS easily, either using an automated script or manual deployment.

## Quick Deployment ##

1. Clone the LambdaGPT repository:

```
git clone git@github.com:DaedalusHub/LambdaGPT.git
```

2. Deploy the `install.sh` helper script:

```
cd LambdaGPT/
sh install.sh
```

3. Test the API using the curl command:

```
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {
        "role": "user",
        "content": "How are you?"
      }
    ]
}' \
"<API_GATEWAY_INVOKE_URL>"
```

## Manual Deployment ##

Ensure the following files are in your working directory before running Terraform:

1. `openai_python_layer.zip` - A zip file containing the OpenAI library as a Lambda Layer.
2. `openai_get_api_key.zip` - A zip file containing the Python script for the `openai_get_api_key` Lambda function.
3. `lambdagpt_invoke_api.zip` - A zip file containing the Python script for the `lambdagpt_invoke_api` Lambda function.

## Deployment Steps ##

1. Run `terraform init` to initialize the Terraform working directory.
2. Run `terraform apply` to create the resources defined in main.tf. Confirm the changes by typing yes when prompted.
3. After the resources are created, the API Gateway URL will be displayed as an output. Use this URL to make API calls to the `lambdagpt_invoke_api` Lambda function.

**Note:** Replace `<OPENAI_API_KEY>` in `terraform.tfvars` with your actual OpenAI API key. Replace the ARN in the `get_api_key` function with the actual ARN of the `openai_get_api_key` Lambda function in your AWS account. Set other variables in `tfvars` depending on your settings.
