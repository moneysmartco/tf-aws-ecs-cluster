resource "spotinst_ocean_ecs" "spotinst_auto_scaling" {
  count = "${var.spotinst_enable ? 1 : 0}"

  region       = "${var.spotinst_region}"
  name         = "${var.project_name}-${var.env}"
  cluster_name = "${var.project_name}-${var.env}"

  min_size         = "0"
  max_size         = "1000"
  desired_capacity = "500"

  subnet_ids = "${split(",", var.private_subnet_ids)}"
  whitelist  = "${split(",", var.spotinst_whitelist)}"

  image_id             = "${data.aws_ami.ecs.id}"
  security_group_ids   = ["${aws_security_group.app_sg.id}"]
  key_pair             = "${var.deploy_key_name}"
  user_data            = "${data.template_file.cloud_config.rendered}"
  iam_instance_profile = "${var.iam_instance_profile}"

  associate_public_ip_address = false

  autoscaler {
    is_auto_config = true
    is_enabled     = true
  }

  update_policy {
    should_roll = true

    roll_config {
      batch_size_percentage = 100
    }
  }
}
