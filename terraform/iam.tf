data "aws_iam_user" "my_user" {
  user_name = "${var.user_name}"
}

data "aws_iam_policy_document" "example" {
  statement {
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "ec2_iam_role" {
  name               = "ec2_iam_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "example" {
  # ... other configuration ...

  policy = "${data.aws_iam_policy_document.example.json}"
}
