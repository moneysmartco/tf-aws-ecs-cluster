#!/bin/bash
cluster="${app_name}-${env}"
echo ECS_CLUSTER=$cluster >> /etc/ecs/ecs.config
echo ECS_AVAILABLE_LOGGING_DRIVERS='["json-file","awslogs","syslog"]' >> /etc/ecs/ecs.config

yum update -y ecs-init

start ecs

sleep 10

yum install -y aws-cli jq
instance_arn=$(curl -s http://localhost:51678/v1/metadata | jq -r '. | .ContainerInstanceArn' | awk -F/ '{print $NF}' )
az=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
region=$${az:0:$${#az} - 1}
scalyr_task="scalyr-agent"
datadog_task="dd-agent-task"
aws ecs start-task --cluster "$${cluster}" --task-definition $${scalyr_task} --container-instances $${instance_arn} --region $region
aws ecs start-task --cluster "$${cluster}" --task-definition $${datadog_task} --container-instances $${instance_arn} --region $region

if [ -n "${dd_api_key}" ]; then
    DD_API_KEY="${dd_api_key}" bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/dd-agent/master/packaging/datadog-agent/source/install_agent.sh)"
fi
