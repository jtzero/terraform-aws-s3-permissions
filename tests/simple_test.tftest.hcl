
mock_provider "aws" {

  #mock "aws_iam_policy" "non_destructive_in_bucket_actions" {
  #  bucket = "bucket"
  #}
}

run "s3_permissions" {
  module {
    source = "../"
  }
}

run "test_outputs" {

  #command = plan

  assert {
    condition     = length(run.s3_permissions.non_destructive_in_bucket_actions) > 0
    error_message = "non_destructive_in_bucket_actions should not be empty"
  }

  assert {
    condition     = length(run.s3_permissions.write_in_bucket_actions) > 0
    error_message = "write_in_bucket_actions should not be empty"
  }

  assert {
    condition     = length(run.s3_permissions.non_destructive_bucket_actions) > 0
    error_message = "non_destructive_bucket_actions should not be empty"
  }

  assert {
    condition     = length(run.s3_permissions.read_bucket_actions) > 0
    error_message = "read_bucket_actions should not be empty"
  }

  assert {
    condition     = length(run.s3_permissions.read_in_bucket_actions) > 0
    error_message = "read_in_bucket_actions should not be empty"
  }

  assert {
    condition     = length(run.s3_permissions.destructive_bucket_actions) > 0
    error_message = "destructive_bucket_actions should not be empty"
  }

  assert {
    condition     = length(run.s3_permissions.destructive_in_bucket_actions) > 0
    error_message = "destructive_in_bucket_actions should not be empty"
  }

}

