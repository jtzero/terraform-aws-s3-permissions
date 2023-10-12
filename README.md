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

Currently there is no distinction beteween create and update, if you can create it you can change it's attr's as well.

```

For outputs there are just 4 major combinations (& a read-only technically sub category of non-destructuve)

```
----------+--------------------+-------------------+-----------+
          | destructive        | non-destructive   | read-only |
----------+--------------------+-------------------+-----------+
in-bucket | can read           | can read          | can read  |
          | can create/update  | can create/update | that's it |
          | can delete         | can't update      |           |
          | can update         | can't delete      |           |
----------+--------------------+-------------------+-----------+
(on)bucket| see above          | see above         | see above |
----------+--------------------+-------------------+-----------+
```
