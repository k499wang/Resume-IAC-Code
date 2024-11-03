resource "aws_s3_bucket" "iac-resume-bucket" {
    bucket = "iac-resume-bucket"
}

resource "aws_s3_bucket_website_configuration" "iac-resume-bucket-website-config" {
    bucket = aws_s3_bucket.iac-resume-bucket.id

    index_document {
      suffix = "resume.html"
    }
}


resource "aws_s3_bucket_public_access_block" "iac-resume-bucket-public-access-block" {
    bucket = aws_s3_bucket.iac-resume-bucket.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "iac-resume-versioning_configuration" {
  bucket = aws_s3_bucket.iac-resume-bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_cloudfront_origin_access_identity" "cdn_oai" {
  comment = "Origin Access Identity for CloudFront to access S3 bucket"
}

module "cdn" {
  source = "terraform-aws-modules/cloudfront/aws"

  comment             = "CloudFront distribution for k3-vin-wvng-resume.works"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  # Create and use an Origin Access Identity (OAI) for S3 access
  create_origin_access_identity = true

   origin_access_identities = {
    s3_bucket_one = aws_cloudfront_origin_access_identity.cdn_oai.id
  }

  # Origin configuration pointing to the S3 bucket
  origin = {
    s3_one = {
      domain_name = aws_s3_bucket.iac-resume-bucket.bucket_regional_domain_name
      s3_origin_config = {
        origin_access_identity = "s3_bucket_one"
      }
    }
  }

  # Default cache behavior configuration
  default_cache_behavior = {
    target_origin_id       = "s3_one"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = false
  }

  # SSL certificate configuration for HTTPS using your ACM certificate
  viewer_certificate = {
    acm_certificate_arn = "arn:aws:acm:us-east-1:596223681353:certificate/7b45f9fd-63e7-4100-b4fa-a6977e916c1c"
    ssl_support_method  = "sni-only"
  }
}

# S3 bucket policy to allow access from CloudFront only
resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.iac-resume-bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.cdn_oai.iam_arn
        },
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.iac-resume-bucket.arn}/*"  # Use ARN here
      }
    ]
  })
}

