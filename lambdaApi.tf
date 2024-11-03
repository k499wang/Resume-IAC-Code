# Create IAM role for Lambda function with permissions for DynamoDB
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-dynamodb-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies to allow Lambda to interact with DynamoDB
resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name   = "lambda-dynamodb-policy"
  role   = aws_iam_role.lambda_exec_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ],
        Resource = "arn:aws:dynamodb:*:*:table/Cloud-Resume-Database"
      }
    ]
  })
}

# Lambda function code to access DynamoDB
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "view_counter" {
  function_name = "cloud_resume_view_counter"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_exec_role.arn
  filename      = data.archive_file.lambda_zip.output_path
  environment {
    variables = {
      TABLE_NAME = "Cloud-Resume-Database"
    }
  }
}

# Create a Lambda Function URL
resource "aws_lambda_function_url" "view_counter_url" {
  function_name = aws_lambda_function.view_counter.function_name
  authorization_type = "NONE"  # Publicly accessible
}

# Output the Lambda Function URL
output "lambda_function_url" {
  value = aws_lambda_function_url.view_counter_url
}
