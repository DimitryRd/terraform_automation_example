# ЦІЛЬ:
Nginx, serving helloWorld index.html originally stored in S3 bucket.

## AWS РЕСУРСИ, ЩО МОЖУТЬ ТОБІ ЗНАДОБИТИСЯ
### (не абсолютно всі вони, тож обирай, що найбільше підійде саме тобі):
- AWS Auto Scaling Group
- AWS Lambda function
- AWS S3 bucket
- AWS S3 bucket policy
- Amazon AMI image
- EBS volume
- EC2 KeyPair
- EC2 instance
- IAM policy
- IAM role
- IAM user

### ДОДАТКОВІ ВИМОГИ:
- index.html should survive shutdown/startup cycle
- Nginx can be either pre-installed or setup during startup
- Solution should be consistent and reproducible (no manual steps)

### Тобі залишається написати свій солюшн, щоб досягти цілі :)


### Terraform command
```
terraform init
terraform apply -> Then please enter your AWS profile name which is located in $HOME/.aws/credentials
```

#### In the end please do
```
terraform destroy --auto-approve
```

# Expected result

![Expected result](Result.png)

### Useful links

1. Terraform AWS manual
https://www.terraform.io/docs/providers/aws/

2. INTRODUCTION TO TERRAFORM WITH AWS ELB & NGINX
https://www.bogotobogo.com/DevOps/Terraform/Terraform-Introduction-AWS-elb-nginx.php

3. https://davidburgos.blog/nginx-to-serve-statics-from-amazon-s3/

4. https://medium.com/@hmalgewatta/setting-up-an-aws-ec2-instance-with-ssh-access-using-terraform-c336c812322f

5. https://github.com/gruntwork-io/terratest/tree/master/examples/terraform-remote-exec-example

6. https://www.digitalocean.com/community/tutorials/how-to-set-up-nginx-virtual-hosts-server-blocks-on-ubuntu-12-04-lts--3

7. https://medium.com/tensult/aws-how-to-mount-s3-bucket-using-iam-role-on-ec2-linux-instance-ad2afd4513ef

8. https://labs.tadigital.com/index.php/2018/06/15/how-to-mount-s3-bucket-on-linux-aws-ec2-instance/