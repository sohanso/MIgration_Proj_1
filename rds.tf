## RDS POSTGRESQL DATABASE ##
resource "aws_db_instance" "migration_rds_postgre" {
    instance_class       = "db.t3.medium"
    identifier           = var.rds_name
    db_name              = "rdscustomerdb"
    allocated_storage    = 20
    apply_immediately    = true
    availability_zone    = local.availability-zones[0]
    multi_az             = false
    backup_retention_period = 7
    backup_window        = "11:00-11:32"
    db_subnet_group_name = local.db_subnet_group_name
    engine               = var.rds_engine
    engine_version       = var.rds_engine_ver
    auto_minor_version_upgrade = true
    storage_type         = "gp3"
    port                 = 5432
    storage_encrypted    = true
    username             = var.rds_username
    password             = var.rds_password
    skip_final_snapshot  = true
    maintenance_window   = "Sun:10:00-Sun:10:32"
    vpc_security_group_ids = [aws_security_group.pg_rds_sg.id]
    snapshot_identifier = null

    dynamic "restore_to_point_in_time" {
      for_each = var.restore_to_point_in_time
      content {
        restore_time = restore_to_point_in_time.value["restore_time"]
        source_db_instance_identifier = restore_to_point_in_time.value["source_db_instance_identifier"]
        source_dbi_resource_id = restore_to_point_in_time.value["source_dbi_resource_id"]
        use_latest_restorable_time = restore_to_point_in_time.value["use_latest_restorable_time"]
    }

  }
}

## SG- RDS ##
resource "aws_security_group" "pg_rds_sg" {
  name        = "postgres rds SG"
  description = "Allow ec2 inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "open to asg ec2"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.on-prem-vpc-cidr, var.cloud-vpc-cidr]

  }
  ingress {
    description = "open to asg ec2"
    from_port   = 20
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.on-prem-vpc-cidr, var.cloud-vpc-cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "pg_rds_sg"
    Project = "Migration-1"
  }
}