provider "aws" {
    region = "us-west-2"
}
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
  sensitive   = false
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

# resource "aws_instance" "example" {
#     ami           = "ami-05f9478b4deb8d173"
#     instance_type = "t2.micro"
#     subnet_id     = aws_subnet.just_test_subnet.id
#     vpc_security_group_ids = [aws_security_group.open_all.id]

#     user_data = <<-EOF
#                 #!/bin/bash
#                 echo "Hello, World" > index.xhtml
#                 nohup busybox httpd -f -p 8080 &
#                 EOF

#     user_data_replace_on_change = true

#     tags = {
#     Name = "test_instance"
#     }
# }

resource "aws_security_group" "open_all" {
    name        = "open_all"
    description = "Allow all inbound traffic"
    vpc_id = aws_vpc.just_test.id
    ingress {
        from_port   = var.server_port
        to_port     = var.server_port
        protocol    = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

  
}
resource "aws_launch_template" "just_test_launch_configuration" {
  
    name          = "example-launch-configuration"
    image_id     = "ami-05f9478b4deb8d173"
    instance_type = "t2.micro"
    network_interfaces {
        security_groups = [aws_security_group.open_all.id]
    }    
    user_data =base64encode(<<-EOF
                echo "Hello, World" > index.xhtml
                nohup busybox httpd -f -p 8080 &
                EOF
    )
    lifecycle {
        create_before_destroy = true
    }

}

resource "aws_autoscaling_group" "just_test_auto_scale" {
    launch_template {
        id      = aws_launch_template.just_test_launch_configuration.id
        version = "$Latest"
    }
    min_size             = 1
    max_size             = 3
    desired_capacity     = 1
    vpc_zone_identifier  = [aws_subnet.just_test_subnet.id]
    health_check_type    = "EC2"
    force_delete          = true

    tag {
        key                 = "Name"
        value               = "test_instance"
        propagate_at_launch = true
    }
  
}

# output "instance_public_ip" {
#     value = aws_instance.example.public_ip
#     description = "value of the public IP address of the instance"
  
# }

