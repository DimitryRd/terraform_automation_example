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
  # associate_public_ip_address = true
  security_groups = ["${aws_security_group.ingress-all-test.id}"]
  subnet_id = "${aws_subnet.subnet-uno.id}"

  tags = {
    Name = "Terraform_${timestamp()}"
  }
}


resource "null_resource" "file_upload" {
  triggers = {
    public_ip = "${aws_eip.ip-test-env.public_ip}"
  }

  connection {
    # The default username for our AMI
    type = "ssh"
    # host = "${aws_instance.ec2_instance.public_ip}"
    host = "${aws_eip.ip-test-env.public_ip}"
    user = "ubuntu"
    private_key = "${file("~/.ssh/deployment-key")}"
    agent = true
  }

  provisioner "file" {
    source      = "./index.html"
    destination = "/home/ubuntu/index.html"
  }
  provisioner "file" {
    source      = "./nginx.conf"
    destination = "/home/ubuntu/nginx.conf"
  }

  provisioner "remote-exec" {
   inline = [
    "sudo rm /usr/share/nginx/html/index.html /etc/nginx/nginx.conf",
    "sudo cp /home/ubuntu/index.html /usr/share/nginx/html/index.html",
    "sudo cp /home/ubuntu/nginx.conf /etc/nginx/nginx.conf",
    "sudo service nginx restart"
   ]
  }
}
output "eip" {
  value = "${aws_eip.ip-test-env}"
}

output "ip" {
  value = "${aws_instance.ec2_instance.public_ip}"
}

output "vpc" {
  value = "${aws_vpc.test-env}"
}

output "subnet" {
  value = "${aws_subnet.subnet-uno}"
}
output "sec_group" {
  value = "${aws_security_group.ingress-all-test}"
}

resource "aws_s3_bucket" "b" {
  bucket = "my-fucking-bucket"
  acl = "private"
  force_destroy = true
  tags = {
    Name = "Nginx bucket"
    Environment = "Dev"
  }
  versioning {
    enabled = false
  }

  # provisioner "local-exec" {
  #    command = "aws s3 cp index.html s3://${aws_s3_bucket.b}"
  # }
}

output "my_bucket" {
  value = "${aws_s3_bucket.b}"
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
