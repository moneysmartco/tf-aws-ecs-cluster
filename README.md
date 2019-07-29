# ECS infrastructure
[![CircleCI](https://circleci.com/gh/moneysmartco/tf-aws-ecs.svg?style=svg&circle-token=xxx)](https://circleci.com/gh/moneysmartco/tf-aws-ecs)

Create ECS cluster with EC2 autoscaling


## Dependencies

Datadog API Key in AWS Parameter Store.

Do ensure that 'dd_api_key' is available in Parameter Store as a SecureString.

The command to retrieve the API key from Parameter Store is embedded inside user-data.sh. It will be executed during system init, make an AWS call to SSM to fetch the value in plain text.

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
