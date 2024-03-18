terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region = var.region_aws
}

# resource "aws_instance" "app_server" {
#     ami = var.instance_ami
#     instance_type = var.instance_size
#     key_name = var.ssh_key
#     tags = {
#       Name = "IACLABMOD2"
#     }
# }

resource "aws_launch_template" "app_maquinas" {
  image_id = var.instance_ami
  instance_type = var.instance_size
  key_name = var.ssh_key
  tags = {
    Name = "ALURAMOD3"
  }
  security_group_names = [ var.security_group ]
  user_data = var.is_prod ? filebase64("ansible.sh") : ""
}

resource "aws_key_pair" "ssh_key_env" {
  key_name = var.ssh_key
  public_key = file("${var.ssh_key}.pub")
}

# output "PUBLIC_IP" {
#   value = aws_instance.app_server.public_ip
# }

resource "aws_autoscaling_group" "ac_group" {
  availability_zones = [ "${var.region_aws}a", "${var.region_aws}b" ]
  name = var.group_name
  max_size = var.group_max_size
  min_size = var.group_min_size
  launch_template {
    id = aws_launch_template.app_maquinas.id
    version = "$Latest"
  }
  target_group_arns = var.is_prod ? [ aws_lb_target_group.target_load_balancer[0].arn ] : []
}

resource "aws_autoscaling_schedule" "ac_group_schedule_on" {
  scheduled_action_name  = "ac-group-schedule-on"
  min_size               = 0
  max_size               = 1
  desired_capacity       = 1
  start_time             = timeadd(timestamp(), "10m")
  recurrence = "0 10 * * MON-FRI" #FUSO HORARIO UTC
  autoscaling_group_name = aws_autoscaling_group.ac_group.name
}

resource "aws_autoscaling_schedule" "ac_group_schedule_off" {
  scheduled_action_name  = "ac-group-schedule-off"
  min_size               = 0
  max_size               = 1
  desired_capacity       = 0
  start_time             = timeadd(timestamp(), "11m")
  recurrence = "0 21 * * MON-FRI" #FUSO HORARIO UTC
  autoscaling_group_name = aws_autoscaling_group.ac_group.name
}

resource "aws_default_subnet" "subnet_1" {
  availability_zone = "${var.region_aws}a"
}

resource "aws_default_subnet" "subnet_2" {
  availability_zone = "${var.region_aws}b"
}

resource "aws_lb" "load_balancer" {
  internal = false
  subnets = [ aws_default_subnet.subnet_1.id, aws_default_subnet.subnet_2.id ]
  security_groups = [ aws_security_group.team_access_group.id ]
  count = var.is_prod ? 1 : 0
}

resource "aws_lb_target_group" "target_load_balancer" {
  name = "app-maquinas-target"
  port = "8000"
  protocol = "HTTP"
  vpc_id = aws_default_vpc.default.id
  count = var.is_prod ? 1 : 0
}

resource "aws_default_vpc" "default" {
    
}

resource "aws_lb_listener" "inbound_load_balancer" {
  load_balancer_arn = aws_lb.load_balancer[0].arn
  port = "8000"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target_load_balancer[0].arn
  }
  count = var.is_prod ? 1 : 0
}

resource "aws_autoscaling_policy" "autoscaling-prod" {
  name = "auto-prod-policy"
  autoscaling_group_name = var.group_name
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
  count = var.is_prod ? 1 : 0
}