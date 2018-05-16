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
variable "vpc_cidr" {
  default = "x.x.x.x/16"
}
variable "azs" {
  default = "ap-southeast-1a,ap-southeast-1b"
}
variable "private_subnet_ids" {
  default = "x-xxx"
}
variable "nat_gateway_azs" {
  default = "x-xxx"
}
## Bastion
variable "bastion_sg_id" {
  default = "sg-xxx"
}
## ALB
variable "alb_sg_id" {
  default = "sg-xxx"
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
variable "asg_cpu_alarm_scale_out_evaulation_periods" {
  default = 1
}
variable "asg_cpu_alarm_scale_in_threshold" {
  default = 5
}
variable "asg_cpu_alarm_scale_in_evaulation_periods" {
  default = 5
}
