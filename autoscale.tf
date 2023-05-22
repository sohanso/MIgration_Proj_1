
## LAUNCH TEMPLATE ##
resource "aws_launch_template" "asg_template" {
  name  = "asg_launch_temp"
  vpc_security_group_ids = [aws_security_group.pgadmin_sg.id]
  image_id      = var.ami_id_for_asg
  instance_type = "t3.micro"
  user_data = filebase64("apache.sh")
}

## AUTO SCALING GROUP ##
resource "aws_autoscaling_group" "pgadmin_asg" {
  name = "cloud-auto-scaling-group"
  vpc_zone_identifier = module.vpc.private_subnets
  desired_capacity   = 2
  max_size           = 3
  min_size           = 1
  health_check_grace_period = 400
  health_check_type         = "ELB"
  target_group_arns = [aws_lb_target_group.alb_tg.arn]

  launch_template {
    id = aws_launch_template.asg_template.id
    version = aws_launch_template.asg_template.latest_version
  }
}