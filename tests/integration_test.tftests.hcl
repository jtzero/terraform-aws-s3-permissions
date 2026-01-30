
mock_provider "aws" {}

run "loads data" {

  command = plan

  module "s3_permissions" {
    source = "../"
  }

  assert {
    condition     = length(module.s3_permissions.non_destructive_in_bucket_actions) > 0
    error_message = "non_destructive_in_bucket_actions should not be empty"
  }

  assert {
    condition     = length(module.s3_permissions.write_in_bucket_actions) > 0
    error_message = "write_in_bucket_actions should not be empty"
  }

  assert {
    condition     = length(module.s3_permissions.non_destructive_bucket_actions) > 0
    error_message = "non_destructive_bucket_actions should not be empty"
  }

  assert {
    condition     = length(module.s3_permissions.read_bucket_actions) > 0
    error_message = "read_bucket_actions should not be empty"
  }

  assert {
    condition     = length(module.s3_permissions.read_in_bucket_actions) > 0
    error_message = "read_in_bucket_actions should not be empty"
  }

  assert {
    condition     = length(module.s3_permissions.destructive_bucket_actions) > 0
    error_message = "destructive_bucket_actions should not be empty"
  }

  assert {
    condition     = length(module.s3_permissions.destructive_in_bucket_actions) > 0
    error_message = "destructive_in_bucket_actions should not be empty"
  }

}

