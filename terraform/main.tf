provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name
  
  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "archive"
    enabled = true

    prefix  = var.source_folder_name
    transition {
      days          = 1/24
      storage_class = "STANDARD_IA"
    }
  }

  lifecycle_rule {
    id      = "purge"
    enabled = true

    prefix  = var.source_folder_name
    expiration {
      days = 1
    }
  }
}

resource "aws_iam_role" "replication_role" {
  name = "replication_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "replication_policy" {
  name = "replication_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.example.bucket}/*"
        ]
      },
      {
        Action = [
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.example.bucket}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "replication_policy_attachment" {
  role       = aws_iam_role.replication_role.name
  policy_arn = aws_iam_policy.replication_policy.arn
}

resource "aws_s3_bucket_replication_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  role = aws_iam_role.replication_role.arn

  rules {
    id     = "replicate-logs"
    status = "Enabled"

    filter {
      prefix = var.source_folder_name
    }

    destination {
      bucket        = aws_s3_bucket.example.arn
      prefix        = var.destination_folder_name
      storage_class = "STANDARD"
    }
  }
}


