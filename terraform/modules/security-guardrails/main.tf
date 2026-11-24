resource "aws_guardduty_detector" "main" {
  enable = true
}

# Default standards (AWS FSBP + CIS) run their checks as AWS Config rules, which is the
# main ongoing cost. Off by default for a lab; turn on for real compliance coverage.
resource "aws_securityhub_account" "main" {
  enable_default_standards = var.enable_securityhub_default_standards
}

resource "aws_config_configuration_recorder" "main" {
  name     = "${var.project_name}-config-recorder"
  role_arn = aws_iam_role.config.arn
}

resource "aws_config_delivery_channel" "main" {
  name           = "${var.project_name}-config-channel"
  s3_bucket_name = aws_s3_bucket.config.bucket
  depends_on     = [aws_config_configuration_recorder.main, aws_s3_bucket_policy.config]
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.main]
}

resource "random_id" "suffix" { byte_length = 4 }
resource "aws_s3_bucket" "config" {
  bucket        = "${var.project_name}-config-${random_id.suffix.hex}"
  force_destroy = var.force_destroy
}
resource "aws_s3_bucket_public_access_block" "config" {
  bucket                  = aws_s3_bucket.config.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "config" {
  name = "${var.project_name}-aws-config-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "config.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

data "aws_caller_identity" "current" {}

# AWS Config needs explicit bucket permissions to deliver snapshots and history.
data "aws_iam_policy_document" "config_bucket" {
  statement {
    sid = "AWSConfigBucketPermissionsCheck"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl", "s3:ListBucket"]
    resources = [aws_s3_bucket.config.arn]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid = "AWSConfigBucketDelivery"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.config.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_s3_bucket_policy" "config" {
  bucket     = aws_s3_bucket.config.id
  policy     = data.aws_iam_policy_document.config_bucket.json
  depends_on = [aws_s3_bucket_public_access_block.config]
}
