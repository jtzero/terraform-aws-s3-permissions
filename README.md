# terraform-aws-s3-permissions

Data only module that breaks down s3 iam permissions into 4 major combinations (& a read-only)

```
----------+-------------+-----------------+
          | destructive | non-destructive |
----------+-------------+-----------------+
in-bucket |             |                 |
----------+-------------+-----------------+
(on)bucket|             |                 |
----------+-------------+-----------------+
```
