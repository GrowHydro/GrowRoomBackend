output "function_name" {
  description = "Name of the Lambda Function"
  value       = aws_lambda_function.hello_world
}

output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_stage.lambda.invoke_url
}


output "website_cdn_id" {
  value = aws_cloudfront_distribution.website_cdn.id
}

output "website_endpoint" {
  value = aws_cloudfront_distribution.website_cdn.domain_name
}

output "aws_s3_bucket"{
    value = aws_s3_bucket.front-end
}