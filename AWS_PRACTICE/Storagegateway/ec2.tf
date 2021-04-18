#creating aws_Web_instance
resource "aws_instance" "Whiteserver" {
  ami           =  "ami-0742b4e673072066f"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "laptopkey"
  subnet_id = "${aws_subnet.Webserver.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_tls.id}"]
  private_ip = "10.5.1.100"
  associate_public_ip_address = true	
  tags = {
    Name = "WhiteServer"
  }
}

#creating additional storage for the SGinstance
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.testing.id
  instance_id = aws_instance.Sg.id
}

#Giving disk space as a cache
data "aws_storagegateway_local_disk" "test" {
  depends_on = ["aws_volume_attachment.ebs_att"]
  disk_path   = aws_volume_attachment.ebs_att.device_name
  gateway_arn = aws_storagegateway_gateway.storage_gateway.arn
}

#creating aws_storage-gateway_instance
resource "aws_instance" "Sg" {
  ami           =  "ami-03d135d4252deff32"
  instance_type = "m4.xlarge"
  availability_zone = "us-east-1a"
  key_name = "laptopkey"
  subnet_id = "${aws_subnet.Webserver.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_tls.id}"]
  private_ip = "10.5.1.200"
  associate_public_ip_address = true	
  tags = {
    Name = "Storagegateway"
  }
}


resource "null_resource" "Fileinstall"{
    depends_on = ["aws_instance.Whiteserver"] 
     provisioner "remote-exec"{
         connection{
          type = "ssh"
          user = "ec2-user"
          private_key = "${file("C:/Users/sitar/Downloads/laptopkey.pem")}"
          #host = "${element(aws_instance.devops_test.*.public_ip,count.index)}"
          host  = "${aws_instance.Whiteserver.public_ip}"
      }
      inline = [
          "sudo yum update -y",
          "sudo mkdir mytestfolder "

      ]
  }
  #depends_on = [aws_instance.devops_test]
}