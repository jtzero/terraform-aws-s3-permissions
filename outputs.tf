output "non_destructive_in_bucket_actions" {
  value = concat([
    "s3:AbortMultipartUpload",
  ], local.read_in_bucket_actions, local.create_in_bucket_actions)
  description = "Non-destructive actions that operate in the bucket"
}

output "write_in_bucket_actions" {
  value = concat([
    "s3:AbortMultipartUpload",
  ], local.create_in_bucket_actions)
  description = "Write actions that operate in the bucket"
}

output "non_destructive_bucket_actions" {
  value       = concat(local.create_bucket_actions, local.read_bucket_actions)
  description = "Non destructive s3 IAM actions that operate on the bucket"
}

output "read_bucket_actions" {
  value       = local.read_bucket_actions
  description = "S3 IAM actions that allow listing and reading on the bucket"
}

output "read_in_bucket_actions" {
  value       = local.read_in_bucket_actions
  description = "S3 IAM actions that allow listing and reading in the bucket"
}

output "destructive_bucket_actions" {
  value = concat([
    "s3:BypassGovernanceRetention",
  ], local.delete_bucket_actions)
  description = "Destructive s3 IAM actions that operate on the bucket"
}

output "destructive_in_bucket_actions" {
  value       = local.delete_in_bucket_actions
  description = "Destructive actions that operate in the bucket"
}
