# ECS infrastructure
[![CircleCI](https://circleci.com/gh/moneysmartco/tf-aws-ecs.svg?style=svg&circle-token=xxx)](https://circleci.com/gh/moneysmartco/tf-aws-ecs)

Create ECS cluster with EC2 autoscaling

## Run with terraform

Update necessary variables and settings in terraform.tfvars following the sample file.

```
## Init the project
terraform init

## Download all remote modules
terrafrom get

## Prepare the output and verify
terraform plan

## Apply to AWS
terraform apply
```
