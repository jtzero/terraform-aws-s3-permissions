# terraform-aws-s3-permissions

Data only module that breaks down s3 iam permissions into 6 groups as locals in main.tf
```
----------+----------------+---------------+
          | create/update  | read | delete |
----------+----------------+------+--------+
in-bucket |                |      |        |
----------+----------------+------+--------+
(on)bucket|                |      |        |
----------+----------------+------+--------+

Currently there is no distinction beteween create and update, if you can 
create it you can change it's attr's as well.

```

For outputs there are just 4 major combinations

```
------------+--------------------+-------------------+
output name | destructive_       | non_destructive_  |
------------+--------------------+-------------------+
in-bucket   | can read           | can read          |  read_ 
            | can create/update  | can create/update |  write_
            | can delete         | can't delete      |  
------------+--------------------+-------------------+
(on)bucket  | see above          | see above         |
------------+--------------------+-------------------+
```

## On vs In
In is for effecting files "in" the bucket, typically the `*` in `arn:aws:s3:::mybucket/*`
On is for properties related to the bucket itself, typically the resource is just `arn:aws:s3:::mybucket`
example
in
```hcl
data "aws_iam_policy_document" "terraform_ci_data_ingestion" {
  version = "2012-10-17"
  statement {
    actions   = ["s3:GetObject"]
    effect    = "Allow"
    resources = ["arn:aws:s3:::mybucket/*"]
  }
}
```
on:
```hcl
data "aws_iam_policy_document" "terraform_ci_data_ingestion" {
  version = "2012-10-17"
  statement {
    actions   = ["s3:PutBucketVersioning"]
    effect    = "Allow"
    resources = ["arn:aws:s3:::mybucket"]
  }
}
```
