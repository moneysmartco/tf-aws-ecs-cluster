#!/bin/bash
cluster="${app_name}-${env}"
echo ECS_CLUSTER=$cluster >> /etc/ecs/ecs.config
echo ECS_AVAILABLE_LOGGING_DRIVERS='["json-file","awslogs","syslog"]' >> /etc/ecs/ecs.config

yum update -y ecs-init

start ecs

# Debugging tool
yum install -y wget htop vim
wget https://github.com/bcicen/ctop/releases/download/v0.7.1/ctop-0.7.1-linux-amd64 -O /usr/local/bin/ctop
chmod +x /usr/local/bin/ctop

amazon-linux-extras install postgresql9.6 -y

sleep 10

# AWS-related tool
yum install -y aws-cli jq
instance_arn=$(curl -s http://localhost:51678/v1/metadata | jq -r '. | .ContainerInstanceArn' | awk -F/ '{print $NF}' )
az=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
region=$${az:0:$${#az} - 1}
scalyr_task="scalyr-agent"
datadog_task="dd-agent-task"
aws ecs start-task --cluster "$${cluster}" --task-definition $${scalyr_task} --container-instances $${instance_arn} --region $region
aws ecs start-task --cluster "$${cluster}" --task-definition $${datadog_task} --container-instances $${instance_arn} --region $region


#run SSM command to retrieve parameters

dd_api_key=$${aws ssm get-parameters --names dd_api_key --with-decryption --query 'Parameters[*].Value' --output text}

if [ -n "$dd_api_key" ]; then
    DD_API_KEY="$dd_api_key" bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/dd-agent/master/packaging/datadog-agent/source/install_agent.sh)"
fi
