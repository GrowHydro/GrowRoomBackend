resource "aws_s3_bucket" "codepipeline-artifacts" {
  bucket = "${var.company}-pipeline-artifacts-${var.env}"
  acl    = "private"
  

  tags = {
    Name        = "s3-artifacts"
    Environment = var.env
  }
}