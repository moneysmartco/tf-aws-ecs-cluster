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
  default     = ""
}

variable "asg_termination_policy" {
  default = ["Default"]
}

## DataDog
variable "dd_api_key" {
  description = "Datadog agent API key"
  default     = ""
}

## ASG
variable "enable_asg_classic_mode" {
  description = "Create Autoscaling Group with standard purchase options (100% ondemand)"
  default     = true
}

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
    "Name"        = ""
    "Country"     = ""
    "Environment" = ""
    "Repository"  = ""
    "Owner"       = ""
    "Department"  = ""
    "Team"        = "shared"
    "Product"     = "common"
    "Project"     = "common"
    "Stack"       = ""
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
variable "enable_asg_mixed_mode" {
  description = "Create Autoscaling Group with multiple purchase options (spot + ondemand)"
  default     = false
}

variable "lt_ebs_device_name" {
  default = "/dev/xvda"
}

variable "asg_lt_ec2_type_1" {
  default = "c4.2xlarge"
}

variable "asg_lt_ec2_type_2" {
  default = "c5.2xlarge"
}

variable "asg_lt_on_demand_base_capacity" {
  description = "Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances."
  default     = 0
}

variable "asg_lt_on_demand_percentage_above_base_capacity" {
  description = "Percentage split between on-demand and Spot instances above the base on-demand capacity."
  default     = 100
}

variable "asg_lt_spot_instance_pools" {
  description = "Number of Spot pools per availability zone to allocate capacity."
  default     = 2
}

## Spotinst
variable "spotinst_enable" {
  default = false
}

variable "spotinst_region" {
  default = "ap-southeast-1"
}

variable "spotinst_whitelist" {
  description = "Instance types to be used by spotinst (default: c3, c4, c5, m3, m4, m5 family)"
  default     = "c3.large,c3.xlarge,c3.2xlarge,c3.4xlarge,c3.8xlarge,c4.large,c4.xlarge,c4.2xlarge,c4.4xlarge,c4.8xlarge,c5.large,c5.xlarge,c5.2xlarge,c5.4xlarge,c5.9xlarge,c5.18xlarge,m3.medium,m3.large,m3.xlarge,m3.2xlarge,m4.large,m4.xlarge,m4.2xlarge,m4.4xlarge,m4.10xlarge,m4.16xlarge,m5.12xlarge,m5.24xlarge,m5.2xlarge,m5.4xlarge,m5.large,m5.xlarge,m5.8xlarge"
}

variable "spotinst_max_size" {
  default = 1000
}

variable "spotinst_min_size" {
  default = 1
}

variable "spotinst_draining_timeout" {
  default = 120
}

# Tags
variable "spotinst_tags_name" {
  default = ""
}

variable "spotinst_tags_country" {
  default = "common"
}

variable "spotinst_tags_environment" {
  default = ""
}

variable "spotinst_tags_repository" {
  default = ""
}

variable "spotinst_tags_owner" {
  default = ""
}

variable "spotinst_tags_department" {
  default = ""
}

variable "spotinst_tags_team" {
  default = "shared"
}

variable "spotinst_tags_product" {
  default = "common"
}

variable "spotinst_tags_project" {
  default = "common"
}

variable "spotinst_tags_stack" {
  default = "shop"
}

variable "spotinst_variable_disk_per_vcpu" {
  default = 5
}

variable "spot_percentage" {
  default = 100
}
