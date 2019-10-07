output "app_sg_id" {
  value = "${aws_security_group.app_sg.id}"
}

output "spotinst_tags" {
  value = "${data.null_data_source.spotinst_tags.*.outputs}"
}
