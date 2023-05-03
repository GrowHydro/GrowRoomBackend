resource "aws_s3_bucket" "codepipeline-artifacts" {
  bucket = "${var.company}-${var.env}-pipeline-artifacts"
  acl    = "private"

  tags = {
    Name        = "s3-artifacts"
    Environment = var.env
  }
}


resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.front-end.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*",
        Resource  = "${aws_s3_bucket.front-end.arn}/*"
      },
    ]
  })
}

resource "aws_s3_bucket" "front-end" {
  bucket = "${var.company}-${var.env}-test"
  
  versioning {
    enabled = true
  }
 server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}



# resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership_2" {
#   bucket = aws_s3_bucket.front-end.id
#   rule {
#     object_ownership = "BucketOwnerEnforced"
#   }
# }

# resource "aws_s3_bucket_acl" "bucket_acl_2" {
#   bucket = aws_s3_bucket.lambda_bucket.id
#   depends_on = [ aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership_2 ]

#    acl    = "public-read"
# }



resource "aws_cloudfront_origin_access_identity" "cloudfront_oia" {
  comment = "example origin access identify"
}

resource "aws_cloudfront_distribution" "website_cdn" {
  enabled = true

  origin {
    origin_id   = "origin-bucket-${aws_s3_bucket.front-end.id}"
    domain_name = aws_s3_bucket.front-end.website_endpoint

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "DELETE", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    min_ttl                = "0"
    default_ttl            = "300"
    max_ttl                = "1200"
    target_origin_id       = "origin-bucket-${aws_s3_bucket.front-end.id}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

