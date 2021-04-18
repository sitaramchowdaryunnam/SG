#Here please input the credientials of your aws account
provider "aws" {
    #aws account IAM user's account access_key
    access_key = "${var.aws_access_key}"
    #aws account IAM user's account secret_key
    secret_key = "${var.aws_secret_key}"
    #aws account region
    region     =  "${var.aws_region}"
}

#Creating a aws_VPC 

resource "aws_vpc" "white" { 
  #we can create the cidr_block in any required region according to our wish 
  cidr_block = "10.5.0.0/16"
  #enabling dns_hostnames
  enable_dns_hostnames = true
  tags       = {
               Name = "white"
               Env  = "Testing-vpc"
  }
}

# creating an aws_subnet
resource "aws_subnet" "Webserver" {
  vpc_id     = "${aws_vpc.white.id}"
  cidr_block = "10.5.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "whitesubnet"

  }
}

#creating an aws_internet_gateway
resource "aws_internet_gateway" "testing_gateway" {
  vpc_id = "${aws_vpc.white.id}"

  tags = {
    Name = "${var.IGW_name}"
  }
}

#creating an aws_routetable
resource "aws_route_table" "routetesting" {
  vpc_id = "${aws_vpc.white.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.testing_gateway.id}"
  }
  tags = {
    Name = "${var.Main_Routing_Table}"
  }
}

#creating an aws_route_table_association
resource "aws_route_table_association" "routetesting_ass" { 
  route_table_id = "${aws_route_table.routetesting.id}"
  subnet_id    = "${aws_subnet.Webserver.id}"

}

#creating a storage gateway
resource "aws_storagegateway_gateway" "storage_gateway" {
  gateway_ip_address = "${aws_instance.Sg.public_ip}"
  gateway_name       = "SG"
  gateway_timezone   = "GMT+9:00"
  gateway_type       = "FILE_S3"
}

#creating additional storage for instance
resource "aws_ebs_volume" "testing" {
  availability_zone = "us-east-1a"
  size              = 50

  tags = {
    Name = "Cache_Sg_instance"
  }
}

#creating Iam_role for the user to give s3_bucket access

resource "aws_iam_role" "S3_bucket_role" {
  name = "S3_bucket_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = "${file("s3_bucket_role.json")}"

  tags = {
    tag-key = "S3_bucket_role"
  }
}


#creating s3_bucket to store the files
resource "aws_s3_bucket" "NEXTFILE" {
  bucket = "terraform7899"
  acl    = "public-read"

  tags = {
    Name        = "terraform7899"
  }
}

#creating nfs_file_share for Storage_gateway
resource "aws_storagegateway_nfs_file_share" "nfs_share" {
  client_list  = ["${aws_instance.Whiteserver.public_ip}","10.0.0.0/16"]
  gateway_arn  = "${aws_storagegateway_gateway.storage_gateway.arn}"
  location_arn = "${aws_s3_bucket.NEXTFILE.arn}"
  role_arn     = "${aws_iam_role.S3_bucket_role.arn}"
  default_storage_class = "S3_ONEZONE_IA"
}
#creating aws_security_group
resource "aws_security_group" "allow_tls" {
  name        = "Allow_all"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.white.id}"

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}


