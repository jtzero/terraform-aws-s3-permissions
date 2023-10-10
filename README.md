# terraform-aws-s3-permissions

Data only module that breaks down s3 iam permissions into 6 groups as locals in main.tf
```
----------+--------+---------------+
          | create | read | delete |
----------+--------+------+--------+
in-bucket |        |      |        |
----------+--------+------+--------+
(on)bucket|        |      |        |
----------+--------+------+--------+

```

For outputs there are just 4 major combinations (& a read-only)

```
----------+-------------+-----------------+
          | destructive | non-destructive |
----------+-------------+-----------------+
in-bucket |             |                 |
----------+-------------+-----------------+
(on)bucket|             |                 |
----------+-------------+-----------------+
```
