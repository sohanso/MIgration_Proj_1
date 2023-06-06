## ON PREMISES APPLICATION SERVER ##

resource "aws_instance" "on_prem_app" {
  ami                         = var.ami_for_appserver
  instance_type               = "t2.medium"
  key_name                    = "ec2key"
#   subnet_id = data.aws_subnet.public_subnet_1.id
#   vpc_security_group_ids = [aws_security_group.on_prem_app_sg.id]
  user_data = templatefile("${path.module}/app_user_data.sh.tpl", {
  db_private_ip       = aws_instance.on_prem_db.private_ip,
  mysql_root_password = local.mysql_root_password
  })
  network_interface {
    network_interface_id = aws_network_interface.app_nic.id
    device_index         = 0
  }


  tags = {
    Name    = "on_prem_appserver"
    Project = "Migration-1"
  }
}

resource "aws_network_interface" "app_nic" {
  subnet_id       = data.aws_subnet.public_subnet_1.id
  security_groups = [aws_security_group.on_prem_app_sg.id]
}
# resource "aws_eip" "app_eip" {
#   vpc = true
#   network_interface = aws_network_interface.app_nic.id
# }

# resource "aws_eip_association" "eip_assoc" {
#   instance_id   = aws_instance.on_prem_app.id
#   allocation_id = aws_eip.app_eip.id
# }


resource "aws_security_group" "on_prem_app_sg" {
  name        = "on-prem-app-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc-on-prem.vpc_id

  ingress {
    description = "open to internet"
    from_port   = 20
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.open-to-public, var.cloud-vpc-cidr]
  }
  ingress {
    description = "open to internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.open-to-public]
  }

  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "on_prem_app_sg"
    Project = "Migration-1"
  }
}