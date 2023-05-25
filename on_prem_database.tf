## ON PREMISES DATABASE SERVER ##

resource "aws_instance" "on_prem_db" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  key_name               = "ec2key"
  subnet_id              = data.aws_subnet.private_subnet_1.id
  vpc_security_group_ids = [aws_security_group.on_prem_db_sg.id]
  user_data = templatefile("${path.module}/db_user_data.sh.tpl", {
  app_private_ip      = aws_network_interface.app_nic.private_ip,
  mysql_root_password = local.mysql_root_password
  })

  tags = {
    Name    = "on_prem_dbserver"
    Project = "Migration-1"
  }
}



resource "aws_security_group" "on_prem_db_sg" {
  name        = "on-prem-db-sg"
  description = "Allow app server inbound traffic"
  vpc_id      = module.vpc-on-prem.vpc_id

  ingress {
    description     = "open to app server"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.on_prem_app_sg.id]
  }
  ingress {
    description     = "open to internet"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.on_prem_app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "on_prem_db_sg"
    Project = "Migration-1"
  }
}