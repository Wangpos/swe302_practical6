# IAM CONFIGURATION - SECURITY FIXES APPLIED
# This file previously demonstrated IAM security misconfigurations
# Now updated with least-privilege principles

# FIX 1: Properly scoped IAM role with least privilege
resource "aws_iam_role" "insecure_role" {
  name = "insecure-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# FIX 2: Least-privilege policy with specific actions and resources
resource "aws_iam_role_policy" "insecure_policy" {
  name = "insecure-policy"
  role = aws_iam_role.insecure_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3ReadWriteSpecificBucket"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::insecure-example-bucket",
          "arn:aws:s3:::insecure-example-bucket/*"
        ]
      },
      {
        Sid    = "DynamoDBReadWrite"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = "arn:aws:dynamodb:us-east-1:*:table/specific-table"
      },
      {
        Sid    = "EC2DescribeOnly"
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups"
        ]
        Resource = "arn:aws:ec2:us-east-1:*:instance/*"
      }
    ]
  })
}

# FIX 4: Remove hardcoded access keys (use IAM roles instead)
# Access keys removed - use IAM roles for EC2 instances or services

# FIX 5-7: IAM user with least-privilege custom policy instead of admin access
resource "aws_iam_user" "insecure_user" {
  name = "service-account"
  path = "/"

  tags = {
    MFARequired = "true"
    Description = "Service account with limited permissions"
  }
}

# Create a custom policy with specific permissions instead of admin access
resource "aws_iam_policy" "service_account_policy" {
  name        = "service-account-policy"
  description = "Least-privilege policy for service account"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3ReadOnly"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::insecure-example-bucket",
          "arn:aws:s3:::insecure-example-bucket/*"
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "service_attach" {
  user       = aws_iam_user.insecure_user.name
  policy_arn = aws_iam_policy.service_account_policy.arn
}

# NOTE: For production environments, also implement:
# - Password rotation policies via AWS account settings
# - Access key rotation via lifecycle management
# - CloudTrail logging for all IAM actions
# - MFA enforcement via IAM policies
