provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
 }


########################################
##### Create Key Pair ##################
########################################



#########################################
##### Create VPC ########################
#########################################


resource "aws_vpc" "rd_vpc" {
  cidr_block      = "10.0.0.0/16"
  instance_tenancy = "default"


  tags = {
    Name = "RD_vpc"
  }
}



#########################################
##### Create Subnet #####################
#########################################



resource "aws_subnet" "rd_subnet_1" {
       vpc_id = "${aws_vpc.rd_vpc.id}"
       availability_zone = "${var.availability_zone}"
       cidr_block = "10.0.1.0/24"
       map_public_ip_on_launch = "true"

       tags = {
            Name = "RD_subnet_1"
  }
}



##########################################
##### Create Internet Gateway ############
##########################################


resource "aws_internet_gateway" "rd_gw" {
       vpc_id = "${aws_vpc.rd_vpc.id}"

  tags = {
    Name = "RD_Gateway"
  }
}




##########################################
##### Create Route Table #################
##########################################


resource "aws_route_table" "rd_prod-public-crt" {
    vpc_id = "${aws_vpc.rd_vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.rd_gw.id}"
  }

    tags = {
        Name = "RD-public-crt"
  }
}



##########################################
##### Associate CRT and Subnet ###########
##########################################


resource "aws_route_table_association" "rd-crta-public-subnet-1" {
    subnet_id = "${aws_subnet.rd_subnet_1.id}"
    route_table_id = "${aws_route_table.rd_prod-public-crt.id}"
}



###########################################
##### Create a Security Group #############
###########################################


resource "aws_security_group" "sg_rd" {
   vpc_id = "${aws_vpc.rd_vpc.id}"


  ingress {
     from_port   = "${var.allow_ports[0]}"
     to_port     = "${var.allow_ports[0]}"
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
}

  ingress {
     from_port   = "${var.allow_ports[1]}"
     to_port     = "${var.allow_ports[1]}"
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
}


ingress {
     from_port   = "${var.allow_ports[2]}"
     to_port     = "${var.allow_ports[2]}"
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
}




  egress {
     from_port   = 0
     to_port     = 0  
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
}

  tags = {
        Name = "RD_SecurityGroup"
    }                       

 }



########################################
##### Create Elastic IP ################
########################################

resource "aws_eip" "rd_eip" {
     instance = "${aws_instance.rd.id}"
}



########################################
##### Create EC2 Instance ##############
########################################


resource "aws_instance" "rd" {
      ami           = "ami-05c1fa8df71875112"
      instance_type = "${var.instance_type}"
      
      # VPC
      subnet_id = "${aws_subnet.rd_subnet_1.id}"

      # Security Group
      vpc_security_group_ids = ["${aws_security_group.sg_rd.id}"]
 
      # the Public SSH key
      key_name = "${var.key_name}"


      tags = {
          Name = "Dev_server"
          Owner = "Devops"
          Poject = "RD"
  }

}

