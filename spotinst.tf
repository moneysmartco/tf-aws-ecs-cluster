data "aws_iam_instance_profile" "ecs" {
  name = var.iam_instance_profile
}

resource "spotinst_ocean_ecs" "spotinst_auto_scaling" {
  count = var.spotinst_enable ? 1 : 0

  region       = var.spotinst_region
  name         = "${var.project_name}-${var.env}"
  cluster_name = "${var.project_name}-${var.env}"

  # Instance type & counts
  whitelist        = split(",", var.spotinst_whitelist)
  min_size         = var.spotinst_min_size
  max_size         = var.spotinst_max_size
  draining_timeout = var.spotinst_draining_timeout
  spot_percentage      = var.spot_percentage

  # Networking
  subnet_ids         = split(",", var.private_subnet_ids)
  image_id           = data.aws_ssm_parameter.ecs.value
  security_group_ids = [aws_security_group.app_sg.id]

  # Metadata
  key_pair             = var.deploy_key_name
  user_data            = data.template_file.cloud_config.rendered
  iam_instance_profile = data.aws_iam_instance_profile.ecs.arn
  monitoring           = true # Detailed monitoring
  
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = "true"
      encrypted = "false"
      volume_type = var.root_ebs_type
      dynamic_volume_size {
        base_size = var.root_ebs_size
        resource = "CPU"
        size_per_resource_unit = var.spotinst_variable_disk_per_vcpu
      }
    }
  }
  autoscaler {
    is_auto_config = true
    is_enabled     = true
  }

  tags {
    key   = "Name"
    value = var.spotinst_tags_name
  }
  tags {
    key   = "Country"
    value = var.spotinst_tags_country
  }
  tags {
    key   = "Environment"
    value = var.spotinst_tags_environment
  }
  tags {
    key   = "Repository"
    value = var.spotinst_tags_repository
  }
  tags {
    key   = "Owner"
    value = var.spotinst_tags_owner
  }
  tags {
    key   = "Department"
    value = var.spotinst_tags_department
  }
  tags {
    key   = "Team"
    value = var.spotinst_tags_team
  }
  tags {
    key   = "Product"
    value = var.spotinst_tags_product
  }
  tags {
    key   = "Project"
    value = var.spotinst_tags_project
  }
  tags {
    key   = "Stack"
    value = var.spotinst_tags_stack
  }
  tags {
    key   = "datadog-enabled"
    value = "true"
  }
}

