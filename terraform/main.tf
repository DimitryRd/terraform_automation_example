provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
  # shared_credentials_file = "/Users/drudakov/.aws/credentials"
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
  ami = "${data.aws_ami.packer_image.id}"
  instance_type = "${var.instance_type}"
  key_name = "deployment-key"
  security_groups = ["${aws_security_group.ingress-all-test.id}"]
  subnet_id = "${aws_subnet.subnet-uno.id}"

  tags = {
    Name = "Terraform_${data.aws_ami.packer_image.id}"
  }
  provisioner "local-exec" {
    command = "echo ${aws_instance.ec2_instance.public_ip} > ip_address.txt"
  }
}

resource "null_resource" "file_upload" {
  provisioner "file" {
    source      = "./index.html"
    destination = "/usr/share/nginx/html/index.html"

  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    type = "ssh"
    # host = "${aws_instance.ec2_instance.public_ip}"
    host = "${aws_eip.ip-test-env.public_ip}"
    user = "root"
    private_key = "${file("~/.ssh/deployment-key")}"
    # The connection will use the local SSH agent for authentication.
    }
  }
}

# provisioner "remote-exec" {
#   inline = [
#     "sudo apt-get -y update",
#     "sudo apt-get -y install nginx",
#     "sudo service nginx start",
#   ]
# }
# }

output "eip" {
  value = "${aws_eip.ip-test-env}"
}

output "ip" {
  value = "${aws_instance.ec2_instance.public_ip}"
}

resource "aws_s3_bucket" "b" {
  bucket = "my-fucking-bucket"
  acl = "private"


  tags = {
    Name = "Nginx bucket"
    Environment = "Dev"
  }
  versioning {
    enabled = true
  }

  # provisioner "local-exec" {
  #    command = "aws s3 cp ./index.html ${aws_s3_bucket.b}"
  # }
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
  key    = "index.html"
  source = "index.html"
}

output "my_bucket_file_version" {
  value = "${aws_s3_bucket_object.file_upload.version_id}"
}
