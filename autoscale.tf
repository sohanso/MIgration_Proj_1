

resource "aws_launch_template" "asg_template" {
  name  = "asg_launch_temp"
  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
    }
  }
  placement {
    availability_zone = "us-central-1a"
  }
  vpc_security_group_ids = [aws_security_group.pgadmin_sg.id]
  image_id      = "ami-03aefa83246f44ef2"
  instance_type = "t3.micro"
}

resource "aws_autoscaling_group" "pgadmin_asg" {
  availability_zones = local.availability-zones
  desired_capacity   = 2
  max_size           = 3
  min_size           = 2
  health_check_grace_period = 400
  health_check_type         = "ELB"
  target_group_arns = [aws_lb_target_group.alb_tg.arn]

  launch_template {
    id = aws_launch_template.asg_template.id
    version = "$Latest"
  }
}