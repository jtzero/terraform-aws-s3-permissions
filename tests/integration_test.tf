module "s3_permissions_test" {
  source = "../"
}

locals {
  non_destructive_in_bucket_actions = module.s3_permissions_test.non_destructive_in_bucket_actions
  write_in_bucket_actions           = module.s3_permissions_test.write_in_bucket_actions
  destructive_bucket_actions        = module.s3_permissions_test.destructive_bucket_actions
  destructive_in_bucket_actions     = module.s3_permissions_test.destructive_in_bucket_actions

  validation_results = {
    non_destructive_in_bucket_has_get_object   = contains(local.non_destructive_in_bucket_actions, "s3:GetObject")
    non_destructive_in_bucket_has_put_object   = contains(local.non_destructive_in_bucket_actions, "s3:PutObject")
    non_destructive_in_bucket_has_abort        = contains(local.non_destructive_in_bucket_actions, "s3:AbortMultipartUpload")
    non_destructive_in_bucket_no_delete_object = !contains(local.non_destructive_in_bucket_actions, "s3:DeleteObject")

    write_in_bucket_has_put_object = contains(local.write_in_bucket_actions, "s3:PutObject")
    write_in_bucket_has_abort      = contains(local.write_in_bucket_actions, "s3:AbortMultipartUpload")
    write_in_bucket_no_get_object  = !contains(local.write_in_bucket_actions, "s3:GetObject")

    destructive_bucket_has_delete_bucket    = contains(local.destructive_bucket_actions, "s3:DeleteBucket")
    destructive_bucket_has_bypass_retention = contains(local.destructive_bucket_actions, "s3:BypassGovernanceRetention")

    destructive_in_bucket_has_delete_object    = contains(local.destructive_in_bucket_actions, "s3:DeleteObject")
    destructive_in_bucket_has_replicate_delete = contains(local.destructive_in_bucket_actions, "s3:ReplicateDelete")
  }
}

output "content_validation_results" {
  description = "Results of content-specific validations"
  value       = local.validation_results
}

data "aws_iam_policy_document" "test_non_destructive_in_bucket" {
  statement {
    actions   = module.s3_permissions_test.non_destructive_in_bucket_actions
    effect    = "Allow"
    resources = ["arn:aws:s3:::test-bucket/*"]
  }

  statement {
    actions   = ["s3:ListBucket"]
    effect    = "Allow"
    resources = ["arn:aws:s3:::test-bucket"]
  }
}

data "aws_iam_policy_document" "test_destructive_bucket" {
  statement {
    actions   = module.s3_permissions_test.destructive_bucket_actions
    effect    = "Allow"
    resources = ["arn:aws:s3:::test-bucket"]
  }
}

resource "aws_iam_policy" "test_non_destructive_policy" {
  name        = "test-non-destructive-s3-policy"
  description = "Test policy for non-destructive S3 actions"
  policy      = data.aws_iam_policy_document.test_non_destructive_in_bucket.json
}

resource "aws_iam_policy" "test_destructive_policy" {
  name        = "test-destructive-s3-policy"
  description = "Test policy for destructive S3 bucket actions"
  policy      = data.aws_iam_policy_document.test_destructive_bucket.json
}
