# TERRAFORM CONFIGURATION - SECURITY FIXES APPLIED
# This file previously demonstrated security misconfigurations
# Now updated with security best practices

resource "aws_s3_bucket" "insecure_example" {
  bucket = "insecure-example-bucket"

  tags = {
    Name        = "Insecure Example"
    Environment = "dev"
  }
}

# FIX 1: Enable server-side encryption (was: No encryption enabled)
resource "aws_s3_bucket_server_side_encryption_configuration" "insecure_example" {
  bucket = aws_s3_bucket.insecure_example.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# FIX 2: Enable versioning for data recovery (was: No versioning)
resource "aws_s3_bucket_versioning" "insecure_example" {
  bucket = aws_s3_bucket.insecure_example.id

  versioning_configuration {
    status = "Enabled"
  }
}

# FIX 3: Add access logging (was: No access logging)
# First, create a logs bucket
resource "aws_s3_bucket" "logs" {
  bucket = "insecure-example-logs"

  tags = {
    Name        = "Logs Bucket"
    Environment = "dev"
  }
}

# Block public access for logs bucket
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable encryption for logs bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable versioning for logs bucket
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "insecure_example" {
  bucket = aws_s3_bucket.insecure_example.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "access-logs/"
}
# FIX 4: Block public access (was: Public access allowed)
resource "aws_s3_bucket_public_access_block" "insecure_example" {
  bucket = aws_s3_bucket.insecure_example.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# FIX 5: Use least-privilege bucket policy (was: Overly permissive)
# Only allow read access, no write or delete permissions for public
resource "aws_s3_bucket_policy" "insecure_example" {
  bucket = aws_s3_bucket.insecure_example.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadOnly"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.insecure_example.arn}/*"
      }
    ]
  })
}

# Another bucket - now with proper configuration
resource "aws_s3_bucket" "backup_insecure" {
  bucket = "backup-insecure-bucket"

  tags = {
    Name        = "Backup Bucket"
    Environment = "dev"
    Purpose     = "Backups"
  }
}

# Block public access for backup bucket
resource "aws_s3_bucket_public_access_block" "backup_insecure" {
  bucket = aws_s3_bucket.backup_insecure.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# FIX 6: Add encryption for backup bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "backup_insecure" {
  bucket = aws_s3_bucket.backup_insecure.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# FIX 7: Add lifecycle policy to manage costs
resource "aws_s3_bucket_lifecycle_configuration" "backup_insecure" {
  bucket = aws_s3_bucket.backup_insecure.id

  rule {
    id     = "transition-old-backups"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

# FIX 8: Enable versioning for backup bucket (MFA delete requires AWS account setup)
resource "aws_s3_bucket_versioning" "backup_insecure" {
  bucket = aws_s3_bucket.backup_insecure.id

  versioning_configuration {
    status = "Enabled"
  }
}
