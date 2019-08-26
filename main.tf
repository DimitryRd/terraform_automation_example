provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  # profile = "${var.profile}"
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
  ami             = "${var.ami_id}"
  instance_type   = "${var.instance_type}"
  key_name        = "${aws_key_pair.generated_key.key_name}"
  security_groups = ["${aws_security_group.ingress-all-test.id}"]
  subnet_id       = "${aws_subnet.subnet-uno.id}"
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
    type        = "ssh"
    host        = "${aws_eip.ip-test-env.public_ip}"
    user        = "ubuntu"
    private_key = "${tls_private_key.example.private_key_pem}"
    agent       = true
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/s3fs/s3fs-1.74.tar.gz",
      "sudo apt-get -y install nginx build-essential gcc libfuse-dev libcurl4-openssl-dev libxml2-dev mime-support pkg-config libxml++2.6-dev libssl-dev",
      "sudo tar -xvzf s3fs-1.74.tar.gz",
      "cd s3fs-1.74",
      "sudo ./configure -prefix=/usr",
      "sudo make",
      "sudo make install",
      "cd /tmp",
      "touch passwd-s3fs",
      "echo '${var.access_key}:${var.secret_key}' > passwd-s3fs",
      "chmod 640 passwd-s3fs",
      "sudo cp passwd-s3fs /etc",
      "sudo s3fs nginx-source-bucket -o use_cache=/tmp -o allow_other -omultireq_max=5 -o nonempty -o uid=$(id -u www-data) /usr/share/nginx/html",
      "sudo service nginx restart"
    ]
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket        = "nginx-source-bucket"
  acl           = "public-read"
  force_destroy = true
  tags = {
    Name        = "Nginx bucket"
    Environment = "Dev"
  }
  versioning {
    enabled = false
  }
}

resource "aws_s3_bucket_object" "file_upload" {
  bucket = "${aws_s3_bucket.bucket.id}"
  key    = "index.html"
  source = "index.html"
}
