resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.company}-pipeline-artifacts-${var.env}-lambda"
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.lambda_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket     = aws_s3_bucket.lambda_bucket.id
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]

  acl = "private"
}

data "archive_file" "lambda_bucket" {
  type        = "zip"
  source_file = "${path.module}/src/index.js"

  output_path = "${path.module}/src/index.zip"

}

resource "aws_s3_object" "lambda_yo_world" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "index.zip"
  source = data.archive_file.lambda_bucket.output_path

  etag = filemd5(data.archive_file.lambda_bucket.output_path)
}

resource "aws_lambda_function" "hello_world" {
  function_name = "HelloWorld"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_yo_world.key

  runtime = "nodejs12.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.lambda_bucket.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "hello_world" {
  name = "/aws/lambda/${aws_lambda_function.hello_world.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
