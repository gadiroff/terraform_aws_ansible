variable "availability_zone" {
    type = string
    default = "us-east-2a"

}



variable "profile" {
    type = string
    default = "rideshairdev"

}


variable "region" {
    type = string
    default = "us-east-2"

}



variable "allow_ports" {
    type    = "list"
    default = ["22", "80", "8080"]
}


variable "instance_type" {
    type = string
    default = "t3.micro"

}


variable "key_name" {
    type = string
    default = "ubuntu_new"
}





variable "ansible_user" {
     type = string
     default = "ubuntu"

}
