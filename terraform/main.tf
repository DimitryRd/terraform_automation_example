provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.key_name}"
  public_key = "${tls_private_key.example.public_key_openssh}"
}

resource "aws_instance" "ec2_instance" {
  ami = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.generated_key.key_name}"
  security_groups = ["${aws_security_group.ingress-all-test.id}"]
  subnet_id = "${aws_subnet.subnet-uno.id}"
  tags = {
    Name = "Terraform_${timestamp()}"
  }
}
resource "local_file" "root_ca_key" {
  content  = "${tls_private_key.example.private_key_pem}"
  filename = "./terraform.pem"
}

resource "null_resource" "file_upload" {
  triggers = {
    public_ip = "${aws_eip.ip-test-env.public_ip}"
  }

  connection {
    # The default username for our AMI
    type = "ssh"
    host = "${aws_eip.ip-test-env.public_ip}"
    user = "ubuntu"
    private_key = "${tls_private_key.example.private_key_pem}"
    agent = true
  }
  provisioner "file" {
    source      = "./index.html"
    destination = "/home/ubuntu/index.html"
  }
  # provisioner "file" {
  #   source      = "./nginx.conf"
  #   destination = "/home/ubuntu/nginx.conf"
  # }
  provisioner "remote-exec" {
   inline = [
    "sleep 60",
    "sudo apt-get -y update",
    "sudo apt-get -y install nginx",
    "sudo service nginx start",
    "sudo rm /usr/share/nginx/html/index.html",
    "sudo cp /home/ubuntu/index.html /usr/share/nginx/html/index.html",
    # "sudo cp /home/ubuntu/nginx.conf /etc/nginx/nginx.conf",
    # "export PATHTONGINX=$(nginx -t)",
    # "cat /etc/nginx/nginx.conf",
    # "ls /etc/nginx/sites-enabled/",
    # "cat /etc/nginx/sites-enabled/default"
   ]
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "nginx-source-bucket"
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

resource "aws_s3_bucket_object" "file_upload" {
  bucket = "${aws_s3_bucket.bucket.id}"
  key    = "index.html"
  source = "index.html"
}
