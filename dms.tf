## Data Migration serivce - replication instance and resources ##

resource "aws_iam_role" "dms-access-for-endpoint" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-access-for-endpoint"
}

resource "aws_iam_role_policy_attachment" "dms-access-for-endpoint-AmazonDMSRedshiftS3Role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role"
  role       = aws_iam_role.dms-access-for-endpoint.name
}

resource "aws_iam_role" "dms-tt-s3-access-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-tt-s3-access-role"
}

resource "aws_iam_role_policy_attachment" "dms-tt-s3-access-role-s3fullaccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.dms-tt-s3-access-role.name
}

resource "aws_iam_role" "dms-cloudwatch-logs-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-cloudwatch-logs-role"
}

resource "aws_iam_role_policy_attachment" "dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
  role       = aws_iam_role.dms-cloudwatch-logs-role.name
}

resource "aws_iam_role" "dms-vpc-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-vpc-role"
}

resource "aws_iam_role_policy_attachment" "dms-vpc-role-AmazonDMSVPCManagementRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  role       = aws_iam_role.dms-vpc-role.name
}

resource "aws_dms_replication_subnet_group" "replication_subnet_group" {
  replication_subnet_group_description = "staging subnets group"
  replication_subnet_group_id          = "repl-subnet-group"

  subnet_ids = module.vpc.database_subnets

  tags = {
    Name = "replication_subnet_group"
    Project = "Migration-1"
  }
  depends_on = [aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole]
}



##REPLICATION INSTANCE ##
resource "aws_dms_replication_instance" "mg_dms_replication" {
  allocated_storage            = 8
  apply_immediately            = true
  auto_minor_version_upgrade   = true
  availability_zone            = local.availability-zones[0]
  publicly_accessible          = false
  replication_instance_class   = "dms.t3.micro"
  replication_instance_id      = "mg-dms-replication-instance"
  replication_subnet_group_id  = aws_dms_replication_subnet_group.replication_subnet_group.id

  tags = {
    Name = "mg_dms_replication_instance"
    Project = "Migration-1"
  }

  vpc_security_group_ids = [aws_security_group.dms_replication_instance_sg.id]

  depends_on = [
    aws_iam_role_policy_attachment.dms-access-for-endpoint-AmazonDMSRedshiftS3Role,
    aws_iam_role_policy_attachment.dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole,
    aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole
  ]
}

## DMS replication instance sg ##
resource "aws_security_group" "dms_replication_instance_sg" {
  name        = "dms_replication_instance_sg"
  description = "Allow inbound traffic"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description = "open to all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "dms_replication_instance_sg"
    Project = "Migration-1"
  }
}

# data "aws_secretsmanager_secret" "secrets" {
#   arn = "arn:aws:secretsmanager:eu-central-1:545960039078:secret:rds!db-75d2d52f-ce5d-42d7-90f2-9e3449f2b94f-RXMb1g"
# }
# data "aws_secretsmanager_secret_version" "current" {
#   secret_id = data.aws_secretsmanager_secret.secrets.id
# }

# ## DMS - ENDPOINTS ##
# resource "aws_dms_endpoint" "dms_source_endpoint" {
#   database_name               = "customer_db"
#   endpoint_id                 = "dms-source-endpoint"
#   endpoint_type               = "source"
#   engine_name                 = "mysql"
#   username                    = "phpmyadmin"
#   password                    = local.mysql_root_password
#   port                        = 3306
#   server_name                 = aws_instance.on_prem_db.private_ip
#   tags = {
#     Name = "dms-source-endpoint"
#     Project = "Migration-1"
#   }
# }

# resource "aws_dms_endpoint" "dms_target_endpoint" {
#   database_name               = "rdscustomerdb"
#   endpoint_id                 = "dms-target-endpoint"
#   endpoint_type               = "target"
#   engine_name                 = "postgres"
#   username                    = var.rds_username
#   password                    = "${jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["password"]}"
#   port                        = 5432
#   server_name                 = aws_db_instance.migration_rds_postgre.address
#   tags = {
#     Name = "dms_target_endpoint"
#     Project = "Migration-1"
#   }
# }

# ## DMS REPLICATION TASK ##

# resource "aws_dms_replication_task" "migration_task_1" {
#   start_replication_task = true
#   migration_type            = "full-load"
#   replication_instance_arn  = aws_dms_replication_instance.mg_dms_replication.replication_instance_arn
#   replication_task_id       = "dms-replication-task-1"
#   replication_task_settings = file("${path.module}/mglab.json")
#   source_endpoint_arn       = aws_dms_endpoint.dms_source_endpoint.endpoint_arn
#   table_mappings            = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"customer_db\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"
#   tags = {
#     Name = "db_migration_task_1"
#   }
#   target_endpoint_arn = aws_dms_endpoint.dms_target_endpoint.endpoint_arn
# }