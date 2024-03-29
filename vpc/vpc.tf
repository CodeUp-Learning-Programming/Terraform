#VPC
resource "aws_vpc" "vpc-tf"{
    cidr_block       = "10.0.0.0/24"
    instance_tenancy = "default"

    tags = {
        Name = "vpc-tf"   
    }
}

#Sub-net
resource 
