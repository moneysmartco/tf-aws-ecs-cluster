#------------------------------
# SG
#------------------------------
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-${var.env}-sg"
  description = "${var.project_name} ${var.env} secgroup"
  vpc_id = "${var.vpc_id}"
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${var.bastion_sg_id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "${var.project_name}-${var.env}-sg"
  }
  lifecycle {
    ignore_changes = ["ingress"]
  }
}

resource "aws_security_group_rule" "alb_to_instances" {
  count                    = "${length(var.alb_sg_ids)}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 32768
  to_port                  = 65535
  source_security_group_id = "${element(var.alb_sg_ids, count.index)}"
  security_group_id        = "${aws_security_group.app_sg.id}"
}

#------------------------------
# ECS
#------------------------------
resource "aws_ecs_cluster" "ecs" {
  name = "${var.project_name}-${var.env}"
}

data "template_file" "cloud_config" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    app_name   = "${var.project_name}"
    env        = "${var.env}"
    dd_api_key = "${var.dd_api_key}"
  }
}

#------------------------------
# Auto-scaling group
#------------------------------
# Use latest ECS AMI
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-ami-versions.html
data "aws_ami" "ecs" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name    = "name"
    values  = ["amzn-ami-*"]
  }
  name_regex = ".*-amazon-ecs-optimized$"
}

resource "aws_launch_configuration" "ecs_lc" {
  name_prefix   = "${var.project_name}-${var.env}-lc-"
  image_id      = "${data.aws_ami.ecs.id}"
  instance_type = "${var.ec2_type}"

  key_name             = "${var.deploy_key_name}"
  user_data            = "${data.template_file.cloud_config.rendered}"
  iam_instance_profile = "${var.iam_instance_profile}"

  security_groups = ["${aws_security_group.app_sg.id}"]

  root_block_device {
    volume_type = "${var.root_ebs_type}"
    volume_size = "${var.root_ebs_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                 = "${var.project_name}-${var.env}-asg"
  launch_configuration = "${aws_launch_configuration.ecs_lc.name}"

  desired_capacity = "${var.asg_desired_capacity}"
  min_size         = "${var.asg_min_size}"
  max_size         = "${var.asg_max_size}"

  vpc_zone_identifier = "${split(",", var.private_subnet_ids)}"

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = [{
    key                 = "Name"
    value               = "${var.project_name}-${var.env}"
    propagate_at_launch = true
  }, {
    key                 = "Project"
    value               = "${var.project_name}"
    propagate_at_launch = true
  }, {
    key                 = "Environment"
    value               = "${var.env}"
    propagate_at_launch = true
  }, {
    key                 = "Type"
    value               = "ec2"
    propagate_at_launch = true
  }, {
    key                 = "datadog-enabled"
    value               = "true"
    propagate_at_launch = true
  }]
}

resource "aws_autoscaling_policy" "asg_scale_out" {
  count                   = "${var.enable_asg_scaling_policy ? 1 : 0}"
  name                    = "${var.project_name}-${var.env}-scale_out-policy"
  scaling_adjustment      = 1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 300
  autoscaling_group_name  = "${aws_autoscaling_group.ecs_asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_out" {
  count               = "${var.enable_asg_scaling_policy ? 1 : 0}"
  alarm_name          = "asg-${var.project_name}-${var.env}-alarm-above-${var.asg_cpu_alarm_scale_out_threshold}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.asg_cpu_alarm_scale_out_evaluation_periods}"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "${var.asg_cpu_alarm_period}"
  statistic           = "Average"
  threshold           = "${var.asg_cpu_alarm_scale_out_threshold}"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.ecs_asg.name}"
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization on ECS ${var.project_name}-${var.env} cluster"
  alarm_actions     = ["${aws_autoscaling_policy.asg_scale_out.arn}"]
}

resource "aws_autoscaling_policy" "asg_scale_in" {
  count                   = "${var.enable_asg_scaling_policy ? 1 : 0}"
  name                    = "${var.project_name}-${var.env}-scale_in-policy"
  scaling_adjustment      = -1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 300
  autoscaling_group_name  = "${aws_autoscaling_group.ecs_asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_in" {
  count               = "${var.enable_asg_scaling_policy ? 1 : 0}"
  alarm_name          = "asg-${var.project_name}-${var.env}-cpu_alarm-below-${var.asg_cpu_alarm_scale_in_threshold}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "${var.asg_cpu_alarm_scale_in_evaluation_periods}"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "${var.asg_cpu_alarm_period}"
  statistic           = "Average"
  threshold           = "${var.asg_cpu_alarm_scale_in_threshold}"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.ecs_asg.name}"
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization on ECS ${var.project_name}-${var.env} cluster"
  alarm_actions     = ["${aws_autoscaling_policy.asg_scale_in.arn}"]
}
