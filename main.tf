provider "aws" {
  region = var.region
  shared_config_files = [var.aws_config_path]
  shared_credentials_files = [var.aws_credentials_path]
  profile = var.aws_profile
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name = "lambda_role_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "lambda:InvokeFunction",
          "lambda:InvokeAsync"
        ]
        Effect   = "Allow"
        Resource = aws_lambda_function.openai_get_api_key.arn
      }
    ]
  })
}

resource "aws_lambda_layer_version" "openai_python_layer" {
  filename            = "openai_python_layer.zip"
  layer_name          = "openai_python_layer"
  compatible_runtimes = ["python3.9"]
}

resource "aws_lambda_function" "openai_get_api_key" {
  function_name = "openai_get_api_key"
  handler       = "get_api_key.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn
  timeout       = 15

  filename = "openai_get_api_key.zip"

  environment {
    variables = {
      openai_api_key = var.openai_api_key
    }
  }
}

resource "aws_lambda_function" "lambdagpt_invoke_api" {
  function_name = "lambdagpt_invoke_api"
  handler       = "invoke_api.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn
  timeout       = 60

  filename = "lambdagpt_invoke_api.zip"

  layers = [
    aws_lambda_layer_version.openai_python_layer.arn
  ]
}

resource "aws_api_gateway_rest_api" "api" {
  name = "LambdaGPT_API"
}

resource "aws_api_gateway_resource" "resource" {
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "invoke"
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "method" {
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.resource.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambdagpt_invoke_api.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambdagpt_invoke_api.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [aws_api_gateway_integration.integration]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name = var.stage
}

output "invoke_url" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.region}.amazonaws.com/prod/invoke"
}