data "aws_iam_instance_profile" "ecs" {
  name = "${var.iam_instance_profile}"
}

resource "spotinst_ocean_ecs" "spotinst_auto_scaling" {
  count = "${var.spotinst_enable ? 1 : 0}"

  region       = "${var.spotinst_region}"
  name         = "${var.project_name}-${var.env}"
  cluster_name = "${var.project_name}-${var.env}"

  # Instance type & counts
  whitelist        = "${split(",", var.spotinst_whitelist)}"
  min_size         = "${var.spotinst_min_size}"
  max_size         = "${var.spotinst_max_size}"
  draining_timeout = "${var.spotinst_draining_timeout}"

  # Networking
  subnet_ids                  = "${split(",", var.private_subnet_ids)}"
  image_id                    = "${data.aws_ssm_parameter.ecs.value}"
  security_group_ids          = ["${aws_security_group.app_sg.id}"]
  associate_public_ip_address = false                                   # Assuming all running in private subnet

  # Metadata
  key_pair             = "${var.deploy_key_name}"
  user_data            = "${data.template_file.cloud_config.rendered}"
  iam_instance_profile = "${data.aws_iam_instance_profile.ecs.arn}"
  monitoring           = true                                          # Detailed monitoring

  autoscaler {
    is_auto_config = true
    is_enabled     = true
  }

  update_policy {
    # Update the config during instance scaling activities
    should_roll = false

    roll_config {
      batch_size_percentage = 20
    }
  }

  tags = [
    {
      key   = "Name"
      value = "${var.spotinst_tags_name}"
    },
    {
      key = "Country"

      // hk in tf-hk
      // sg in tf-sg
      // common in tf-api-common (not working...)
      // common in tf-blog-fe (not working...)
      value = "${var.spotinst_tags_country}"
    },
    {
      key   = "Environment"
      value = "${var.spotinst_tags_environment}"
    },
    {
      key = "Repository"

      // tf-blog-fe in tf-blog-fe
      value = "${var.spotinst_tags_repository}"
    },
    {
      key   = "Owner"
      value = "${var.spotinst_tags_owner}"
    },
    {
      key   = "Department"
      value = "${var.spotinst_tags_department}"
    },
    {
      key = "Team"

      // shared in tf-hk
      // shared in tf-sg
      // shared in tf-api-common
      // shared in tf-blog-fe
      value = "${var.spotinst_tags_team}"
    },
    {
      key = "Product"

      // common in tf-hk
      // common in tf-sg
      // common in tf-api-common
      // v2 in tf-blog-fe
      value = "${var.spotinst_tags_product}"
    },
    {
      key = "Project"

      // hk in tf-hk
      // sg in tf-hk
      // api-common in tf-api-common (not working....)
      // blog-fe in tf-blog-fe (not working....)
      value = "${var.spotinst_tags_project}"
    },
    {
      key = "Stack"

      // shop in tf-hk
      // shop in tf-sg
      // shop in tf-api-common
      // blog in tf-blog-fe
      value = "${var.spotinst_tags_stack}"
    },
    {
      key   = "datadog-enabled"
      value = "true"
    },
  ]
}
