variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "openai_api_key" {
  description = "OpenAI API Key"
  type        = string
  default     = ""
}

variable "stage" {
  description = "Deployment stage"
  type = string
  default = "dev"
}

variable "aws_config_path" {
  description = "Path to AWS Config location."
  type = string
  default = ""
}

variable "aws_credentials_path" {
  description = "Path to AWS Credentials location."
  type = string
  default = ""
}

variable "aws_profile" {
  description = "Name of AWS profile if separate than default."
  type = string
  default = ""
}