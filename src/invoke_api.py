import json
import os
import openai
import boto3

def lambda_handler(event, context):

    message = json.loads(event['body'])
    model_to_use = message['model']
    input_prompt = message['messages']
    ACCOUNT_ID = context.invoked_function_arn.split(":")[4]
    
    openai.api_key = get_api_key(ACCOUNT_ID)
    response = openai.ChatCompletion.create(
      model=model_to_use,
      messages=input_prompt
    )

    return {
        "isBase64Encoded": "false",
        "statusCode":200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"response": response})
    }

def get_api_key(account):
    lambda_client = boto3.client('lambda')
    runtime_region = os.environ['AWS_REGION']
    response = lambda_client.invoke(
            FunctionName = 'arn:aws:lambda:' + runtime_region + ':' + account + ':function:openai_get_api_key',
            InvocationType = 'RequestResponse'
        )

    openai_api_key = json.load(response['Payload'])['body']['api_key']
    return openai_api_key
