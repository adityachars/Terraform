resource "aws_vpc" "aditya-vpc" {
cidr_block = "7.7.0.0/16"
instance_tenancy = "default"
tags = {
Name="aditya-vpc"
}
}

