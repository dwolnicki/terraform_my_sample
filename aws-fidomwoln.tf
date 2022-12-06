


provider "aws" {
    region = "eu-west-1"
    access_key = "AKIAUAMP23ITAXFZ7O5U"
    secret_key = "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"
}   


#resource "resourceName" "MyName" {
#    key1 = "value1"
#    key2 = "value2"
#}

#Step 1
resource aws_vpc "vpc_staging"{

    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "vpc_staging"
    }
}

#Step 2
resource "aws_internet_gateway" "igw_staging"{

    vpc_id = "${aws_vpc.vpc_staging.id}"

    tags = {
        Name = "igw_staging"
    }
}

#Step 3 - Seems that I did't associate this RT with any subnet
resource "aws_route_table" "rt_staging_1"{

    vpc_id = "${aws_vpc.vpc_staging.id}"

    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.igw_staging.id}"
    }
}

#Step 3.b
resource "aws_main_route_table_association" "rt_association_staging_1"{
    vpc_id = "${aws_vpc.vpc_staging.id}"
    route_table_id = "${aws_route_table.rt_staging_1.id}"
}

#Step 4

resource "aws_subnet" "subet_staging_a"{

    vpc_id = "${aws_vpc.vpc_staging.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    

}

#Step 5 - Seems that I have already done it in Step 3

#Step 6
resource "aws_security_group" "sg_staging_http_server"{

    description = "Allow traffic to WEB server"
    vpc_id = "${aws_vpc.vpc_staging.id}"

    tags = {
        Name = "Allow HTTP, HTTPS, SSH"
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

}

#Step 7
resource "aws_network_interface" "eni_web_01"{

    subnet_id = "${aws_subnet.subet_staging_a.id}"
    security_groups = ["${aws_security_group.sg_staging_http_server.id}"]

#    attachment {
#        instance = "${aws_instance.web_server.id}"
#        device_index = -1
#} 

}


#Step 8

#Step 9

resource "aws_instance" "web_server"{

    ami = "ami-01cae1550c0adea9c"
    instance_type = "t2.micro"

    network_interface {
        network_interface_id = "${aws_network_interface.eni_web_01.id}"
        device_index = 0
    }

    key_name = "fidomwolnAWS"
    #associate_public_ip_address =  true

    tags = {
        Name = "WebServerTerra1"


    }

    user_data = <<EOF
        #!/bin/bash
        yum install -y httpd
        sleep 10
        systemctl enable httpd
        systemctl start httpd
        echo "Hello from httpd server created by Dwolnicki using terraform" > /var/www/html/index.html
    EOF



}







