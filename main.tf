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


resource "aws_instance" "example" {
    ami           = "ami-05f9478b4deb8d173"
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.just_test_subnet.id
    vpc_security_group_ids = [aws_security_group.open_all.id]

    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.xhtml
                nohup busybox httpd -f -p 8080 &
                EOF

    user_data_replace_on_change = true

    tags = {
    Name = "test_instance"
    }
}

resource "aws_security_group" "open_all" {
    name        = "open_all"
    description = "Allow all inbound traffic"
    vpc_id = aws_vpc.just_test.id
    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

  
}
