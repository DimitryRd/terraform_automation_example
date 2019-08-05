provider "aws" {
  profile    = "personal"
  region     = "${var.region}"
}

data "aws_iam_policy_document" "example" {
  statement {
    actions   = ["*"]
    resources = ["*"]
  }
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

output "ip" {
  value = "${aws_instance.ec2_instance.public_ip}"
}
