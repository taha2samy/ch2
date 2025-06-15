provider "aws" {
    region = "us-west-2"
}

resource "aws_vpc" "just_test" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
    instance_tenancy     = "default"
    tags = {
        Name = "just_test_vpc"
    }


}

resource "aws_subnet" "just_test_subnet" {
    vpc_id                  = aws_vpc.just_test.id
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone       = "us-west-2a"
    tags = {
        Name = "just_test_subnet"
    }
}

resource "aws_instance" "just_test_instance" {
    ami           = "ami-05f9478b4deb8d173" 
    subnet_id     = aws_subnet.just_test_subnet.id
    instance_type = "t2.micro"
    
    tags = {
        Name = "just_test_instance"
    }
}
