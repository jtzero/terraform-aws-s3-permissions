module "s3_permissions" {
  source = "../../"
}

resource "aws_s3_bucket" "data_bucket" {
  bucket = "data-bucket"
}

data "aws_iam_policy_document" "read_only" {
  statement {
    sid    = "AllowReadOnlyInDataBucketS3Bucket"
    effect = "Allow"
    actions = concat(
      module.s3_permissions.read_in_bucket_actions,
    )
    resources = [
      "${aws_s3_bucket.data_bucket.arn}/*"
    ]
  }
  statement {
    sid    = "AllowReadOnlyOnDataBucketS3Buckets"
    effect = "Allow"
    actions = concat(
      module.s3_permissions.read_bucket_actions,
    )
    resources = [aws_s3_bucket.data_bucket.arn]
  }
}

resource "aws_iam_policy" "read_only" {
  name        = "s3-data-bucket-read-only-permissions"
  path        = "/"
  description = "S3 Read Only"
  policy      = data.aws_iam_policy_document.read_only.json
}

data "aws_iam_policy_document" "this_workspace_permissions" {
  statement {
    sid    = "AllowAthenaWorkspaceInS3Bucket"
    effect = "Allow"
    actions = concat(
      module.s3_permissions.non_destructive_in_bucket_actions,
    )
    resources = ["${aws_s3_bucket.data_bucket.arn}/*"]
  }

  statement {
    sid    = "AllowAthenaWorkspaceOnS3Buckets"
    effect = "Allow"
    actions = concat(
      module.s3_permissions.read_bucket_actions,
    )
    resources = [aws_s3_bucket.data_bucket.arn]
  }
}

resource "aws_iam_policy" "this_workspace_permissions" {
  name        = "athena-user-s3-permissions"
  path        = "/"
  description = "Permissions for generic athena user"
  policy      = data.aws_iam_policy_document.this_workspace_permissions.json
}

data "aws_iam_policy_document" "data_bucket_full_access" {
  statement {
    sid    = "AllowDataBucketInS3FullAccess"
    effect = "Allow"
    actions = concat(
      module.s3_permissions.destructive_in_bucket_actions,
    )
    resources = ["${aws_s3_bucket.data_bucket.arn}/*"]
  }

  statement {
    sid    = "AllowDataBucketOnS3FullAccess"
    effect = "Allow"
    actions = concat(
      module.s3_permissions.destructive_bucket_actions,
    )
    resources = [aws_s3_bucket.data_bucket.arn]
  }

}

resource "aws_iam_policy" "s3_data_engineer" {
  name        = "data-engineer-data-bucket-permissions"
  path        = "/"
  description = "Permissions for data engineer on data bucket"
  policy      = data.aws_iam_policy_document.data_bucket_full_access.json
}


data "aws_iam_policy_document" "bot_bucket_create_new_and_edit" {
  statement {
    sid    = "BotBucketCreateNewAndEdit"
    effect = "Allow"
    actions = concat(
      module.s3_permissions.non_destructive_bucket_actions,
    )
    resources = ["arn:aws:s3:::bot-data-*"]
  }
  statement {
    sid    = "BotBucketEdit"
    effect = "Allow"
    actions = concat(
      module.s3_permissions.non_destructive_in_bucket_actions,
    )
    resources = ["arn:aws:s3:::bot-data-*/*"]
  }
}

resource "aws_iam_policy" "create_new_data_bucket" {
  name        = "BotBucketCreateNewAndEdit"
  path        = "/"
  description = "Permissions for the bot to create new overflow buckets"
  policy      = data.aws_iam_policy_document.bot_bucket_create_new_and_edit.json
}


data "aws_iam_policy_document" "firehose_create_new_files" {
  statement {
    sid    = "FireHoseCreateNewFiles"
    effect = "Allow"
    actions = concat(
      module.s3_permissions.write_in_bucket_actions,
    )
    resources = ["${aws_s3_bucket.data_bucket.arn}/*"]
  }
}

resource "aws_iam_policy" "firehose_create_new_files" {
  name        = "FireHoseCreateNewFiles"
  path        = "/"
  description = "Permissions for the firehose to create new files"
  policy      = data.aws_iam_policy_document.firehose_create_new_files.json
}
