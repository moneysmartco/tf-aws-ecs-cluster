locals {
  # env tag in map structure
  env_tag = { Environment = "${var.env}" }

  # ecs cluster name tag in map structure
  ecs_cluster_name_tag = { Name = "${var.project_name}-${var.env}" }

  # ecs auto scaling group name tag in map structure
  ecs_asg_name_tag = { Name = "${var.project_name}-${var.env}" }

  # enable datadog to be used tag in map structure
  datadog_tag = { datadog-enabled = "true" }

  # ec2 security group name tag in map structure
  app_security_group_name_tag = { Name = "${var.project_name}-${var.env}-sg" }

  #------------------------------------------------------------
  # variables that will be mapped to the various resource block
  #------------------------------------------------------------

  # ecs cluster tags
  ecs_cluster_tags = "${merge(var.tags, local.env_tag, local.ecs_cluster_name_tag)}"

  # ecs asg tags
  ecs_asg_tags = "${merge(var.tags, local.env_tag, local.ecs_asg_name_tag, local.datadog_tag)}"

  # app ec2 security group name tags
  app_security_group_tags = "${merge(var.tags, local.env_tag, local.app_security_group_name_tag)}"
}

# data structure to transform the tags structure(list of maps) required by auto scaling group resource
data "null_data_source" "ecs_asg_tags" {
  count = "${length(local.ecs_asg_tags)}"
  inputs = {
    key = "${element(keys(local.ecs_asg_tags), count.index)}"
    value = "${element(values(local.ecs_asg_tags), count.index)}"
    propagate_at_launch = true
  }
}

#------------------------------
# SG
#------------------------------
resource "aws_security_group" "app_sg" {
  name        = "tf-${var.project_name}-${var.env}-sg"
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
  tags = "${local.app_security_group_tags}"
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
  tags = "${local.ecs_cluster_tags}"
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
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/al2ami.html
data "aws_ami" "ecs" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name    = "name"
    values  = ["amzn2-ami-ecs-hvm-2.0.*"]
  }
  name_regex = ".*-x86_64-ebs$"
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

  min_size         = "${var.asg_min_size}"
  max_size         = "${var.asg_max_size}"

  vpc_zone_identifier = "${split(",", var.private_subnet_ids)}"

  termination_policies = "${var.asg_termination_policy}"

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

  # example of expected structure for tags in auto scaling group
  # tags = [
  #   {
  #    key                 = "Name"
  #    value               = "sg-staging"
  #    propagate_at_launch = true
  #   },
  #   {
  #    key                 = "Environment"
  #    value               = "staging"
  #    propagate_at_launch = true
  #   },
  #   .
  #   .
  #   .
  #   {
  #    key                 = "xxxxxx"
  #    value               = "yyyyyy"
  #    propagate_at_launch = true
  #   }
  # ]
  tags = ["${data.null_data_source.ecs_asg_tags.*.outputs}"]
}

resource "aws_autoscaling_policy" "asg_scale_out" {
  count                   = "${var.enable_asg_scaling_policy ? 1 : 0}"
  name                    = "${var.project_name}-${var.env}-scale_out-policy"
  scaling_adjustment      = 1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = "${var.asg_scale_out_cooldown}"
  autoscaling_group_name  = "${aws_autoscaling_group.ecs_asg.name}"
}

resource "aws_autoscaling_policy" "asg_scale_out_cpu_reservation" {
  count                     = "${var.enable_asg_cpu_reservation_scaling_policy ? 1 : 0}"
  name                      = "${var.project_name}-${var.env}-target-tracking-cpu-reserve-${var.autoscale_cpu_reservation_target_value}-scale-out-policy"
  adjustment_type           = "ChangeInCapacity"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = "${aws_autoscaling_group.ecs_asg.name}"
  estimated_instance_warmup = "${var.estimated_instance_warmup}"
  target_tracking_configuration {
    customized_metric_specification {
      metric_dimension {
        name  = "ClusterName"
        value = "${aws_ecs_cluster.ecs.name}"
        }

        metric_name = "CPUReservation"
        namespace   = "AWS/ECS"
        statistic   = "Average"
        unit        = "Percent"
      }

    target_value = "${var.autoscale_cpu_reservation_target_value}"
  }
}

resource "aws_autoscaling_policy" "asg_scale_out_memory_reservation" {
  count                     = "${var.enable_asg_memory_reservation_scaling_policy ? 1 : 0}"
  name                      = "${var.project_name}-${var.env}-target-tracking-memory-reserve-${var.autoscale_memory_reservation_target_value}-scale-out-policy"
  adjustment_type           = "ChangeInCapacity"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = "${aws_autoscaling_group.ecs_asg.name}"
  estimated_instance_warmup = "${var.estimated_instance_warmup}"
  target_tracking_configuration {
    customized_metric_specification {
      metric_dimension {
        name  = "ClusterName"
        value = "${aws_ecs_cluster.ecs.name}"
        }

        metric_name = "MemoryReservation"
        namespace   = "AWS/ECS"
        statistic   = "Average"
        unit        = "Percent"
      }

    target_value = "${var.autoscale_memory_reservation_target_value}"
  }
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
  cooldown                = "${var.asg_scale_in_cooldown}"
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

resource "aws_autoscaling_lifecycle_hook" "ecs_lifecycle_termination_hook" {
  count                  = "${var.enable_lifecycle_termination_toggle? 1: 0}"

  name                   = "${aws_autoscaling_group.ecs_asg.name}-lifecycle-termination-hook"
  autoscaling_group_name = "${aws_autoscaling_group.ecs_asg.name}"
  default_result         = "${var.lifecycle_default_result}"
  heartbeat_timeout      = "${var.heartbeat_timeout}"
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
}


#------------------------------------------
# Auto-scaling group via Launch Template
#------------------------------------------
resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "${var.project_name}-${var.env}-lt-"
  image_id      = "${data.aws_ami.ecs.id}"
  description   = "Lanuch template for ${var.project_name}-${var.env} at ${timestamp()}"

  key_name             = "${var.deploy_key_name}"
  user_data            = "${base64encode(data.template_file.cloud_config.rendered)}"
  iam_instance_profile {
    name = "${var.iam_instance_profile}"
  }

  block_device_mappings {
    device_name = "${var.lt_ebs_device_name}"

    ebs {
      volume_type = "${var.root_ebs_type}"
      volume_size = "${var.root_ebs_size}"
      iops        = 0
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs_asg_lt" {
  name                 = "${var.project_name}-${var.env}-asg-lt"

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = "${aws_launch_template.ecs_lt.id}"
        version            = "$$Latest"
      }

      override {
        instance_type = "${var.asg_lt_ec2_type_1}"
      }

      override {
        instance_type = "${var.asg_lt_ec2_type_2}"
      }
    }

    instances_distribution {
      on_demand_allocation_strategy            = "${var.asg_lt_on_demand_allocation_strategy}"
      on_demand_base_capacity                  = "${var.asg_lt_on_demand_base_capacity}"
      on_demand_percentage_above_base_capacity = "${var.asg_lt_on_demand_percentage_above_base_capacity}"
      spot_allocation_strategy                 = "${var.asg_lt_spot_allocation_strategy}"
      spot_instance_pools                      = "${var.asg_lt_spot_instance_pools}"
    }
  }

  min_size         = "${var.asg_min_size}"
  max_size         = "${var.asg_max_size}"

  vpc_zone_identifier = "${split(",", var.private_subnet_ids)}"

  termination_policies = "${var.asg_termination_policy}"

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

  # example of expected structure for tags in auto scaling group
  # tags = [
  #   {
  #    key                 = "Name"
  #    value               = "sg-staging"
  #    propagate_at_launch = true
  #   },
  #   {
  #    key                 = "Environment"
  #    value               = "staging"
  #    propagate_at_launch = true
  #   },
  #   .
  #   .
  #   .
  #   {
  #    key                 = "xxxxxx"
  #    value               = "yyyyyy"
  #    propagate_at_launch = true
  #   }
  # ]
  tags = ["${data.null_data_source.ecs_asg_tags.*.outputs}"]
}
