variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
variable "IGW_name" {}
variable "Main_Routing_Table" {}
variable "public_subnet"{}
variable "subnet_name"{}
#variable "peer_owner_id"{}
variable "Name"{
  default = ["Webserver","Database"]
}
 variable "env"{}
 variable "aws_key_name"{}
 variable "aws_ami" {}
#  variable "private_key"{}