provider "aws" {
  profile    = "${var.profile}"
  region     = "${var.region}"
  # shared_credentials_file = "${HOME}/.aws/credentials"
}

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
  name = "ec2_iam_role"
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

data "aws_ami" "packer_image" {
  most_recent = true
  owners = ["self"]
  filter {
    name = "name"
    values = ["packer-example*"]
  }
}
output "ami_id" {
  value = "${data.aws_ami.packer_image.id}"
}

resource "aws_instance" "ec2_instance" {
  ami           = "${data.aws_ami.packer_image.id}"
  instance_type = "${var.instance_type}"

 provisioner "local-exec" {
  command = "echo ${aws_instance.ec2_instance.public_ip} > ip_address.txt"
	}
}

# resource "aws_eip" "eip" {
#   instance = "${aws_instance.ec2_instance.id}"
# }

# output "eip" {
#   value = "${aws_eip.eip}"
# }

output "ip" {
  value = "${aws_instance.ec2_instance.public_ip}"
}

resource "aws_s3_bucket" "b" {
  bucket = "my-fucking-bucket"
  acl = "private"


  tags = {
    Name   = "Nginx bucket"
    Environment = "Dev"
  }
  versioning {
    enabled = true
  }

  provisioner "local-exec" {
     command = "aws s3 cp ./index.html ${aws_s3_bucket.b}"
  }
}

resource "aws_s3_bucket_policy" "b" {
  bucket = "${aws_s3_bucket.b.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "MYBUCKETPOLICY",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::my-fucking-bucket/*",
      "Condition": {
         "IpAddress": {"aws:SourceIp": "8.8.8.8/32"}
      }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_object" "file_upload" {
  bucket = "${aws_s3_bucket.b.id}"
  key = "index.html"
  source = "index.html"
}
output "my_bucket_file_version" {
  value = "${aws_s3_bucket_object.file_upload.version_id}"
}
