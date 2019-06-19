## Project
variable "env" {
  default = "test"
}
variable "project_name" {
  default = "test"
}
## VPC
variable "vpc_id" {
  default = "vpc-xxx"
}
variable "private_subnet_ids" {
  default = "x-xxx"
}
## Bastion
variable "bastion_sg_id" {
  default = "sg-xxx"
}
## ALB
variable "alb_sg_ids" {
  default = ["sg-xxx"]
}
## EC2
variable "deploy_key_name" {
  default = ""
}
variable "root_ebs_size" {
  default = 50
}
variable "root_ebs_type" {
  default = "gp2"
}
variable "ec2_type" {
  default = "t2.medium"
}
variable "iam_instance_profile" {
  description = "Instance profile name for launch configuration / launch template"
  default = ""
}

variable "asg_termination_policy" {
  default = ["Default"]
}

## DataDog
variable "dd_api_key" {
  description = "Datadog agent API key"
  default = ""
}
## ASG
variable "asg_min_size" {
  default = 1
}
variable "asg_max_size" {
  default = 5
}
variable "enable_asg_scaling_policy" {
  default = false
}
variable "enable_asg_cpu_reservation_scaling_policy" {
  default = false
}
variable "enable_asg_memory_reservation_scaling_policy" {
  default = false
}
variable "asg_cpu_alarm_period" {
  default = 60
}
variable "asg_cpu_alarm_scale_out_threshold" {
  default = 60
}
variable "asg_scale_out_cooldown" {
  default = 300
}
variable "asg_cpu_alarm_scale_out_evaluation_periods" {
  default = 1
}
variable "asg_cpu_alarm_scale_in_threshold" {
  default = 5
}
variable "asg_cpu_alarm_scale_in_evaluation_periods" {
  default = 5
}
variable "asg_scale_in_cooldown" {
  default = 300
}
variable "autoscale_cpu_reservation_target_value" {
  default = 60
}
variable "autoscale_memory_reservation_target_value" {
  default = 60
}

variable "estimated_instance_warmup" {
  default = 300
}

variable "tags" {
  description = "Tagging resources with default values"
  default = {
    "Name" = ""
    "Country" = ""
    "Environment" = ""
    "Repository" = ""
    "Owner" = ""
    "Department" = ""
    "Team" = "shared"
    "Product" = "common"
    "Project" = "common"
    "Stack" = ""
  }
}

variable "enable_lifecycle_termination_toggle" {
  default = false
}

variable "heartbeat_timeout" {
  default = 1800
}

variable "lifecycle_default_result" {
  default = "CONTINUE"
}

variable "ecs_user_data" {
  default = ""
}

## Auto Scaling Group in Launch Template
variable "asg_lt_ec2_type_1" {
  default = "m4.large"
}

variable "asg_lt_ec2_type_2" {
  default = "m5.large"
}

variable "asg_lt_on_demand_allocation_strategy" {
  description = "Strategy to use when launching on-demand instances."
  default = "prioritized"
}

variable "asg_lt_on_demand_base_capacity" {
  description = "Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances."
  default = 0
}

variable "asg_lt_on_demand_percentage_above_base_capacity" {
  description = "Percentage split between on-demand and Spot instances above the base on-demand capacity."
  default = 100
}

variable "asg_lt_spot_allocation_strategy" {
  description = "How to allocate capacity across the Spot pools. (diversified / lowest-price)"
  default = "lowest-price"
}

variable "asg_lt_spot_instance_pools" {
  description = "Number of Spot pools per availability zone to allocate capacity."
  default = 2
}
