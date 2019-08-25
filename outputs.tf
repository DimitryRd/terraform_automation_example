output "public_dns" {
  value = "${aws_eip.ip-test-env.public_dns}"
}

# output "vpc" {
#   value = "${aws_vpc.test-env}"
# }

# output "subnet" {
#   value = "${aws_subnet.subnet-uno}"
# }

# output "sec_group" {
#   value = "${aws_security_group.ingress-all-test}"
# }

# output "my_bucket" {
#   value = "${aws_s3_bucket.b}"
# }

# output "my_bucket_file_version" {
#   value = "${aws_s3_bucket_object.file_upload.version_id}"
# }

# output "ami_id" {
#   value = "${data.aws_ami.packer_image.id}"
# }

# output "aws_key_pair" {
#   value = "${aws_key_pair.generated_key}"
# }

# output "tls_private_key" {
#   value = "${tls_private_key.example}"
# }
