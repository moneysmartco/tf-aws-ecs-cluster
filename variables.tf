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
variable "asg_desired_capacity" {
  default = 1
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

variable "enable_lifecycle_toggle" {
  default = false
}

variable "heartbeat_timeout" {
  default = 1800
}

variable "lifecycle_default_result" {
  default = "CONTINUE"
}
