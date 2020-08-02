provider "nomad" {
  address = "http://NOMAD_ADDR:4646"
  region  = "global"
}

resource "aws_efs_file_system" "nomad" {}

module "aws_efs_csi_plugin" {
  source  = "KristophUK/aws-efs-csi-plugin/nomad"
  version = "0.1.1"
}

data "nomad_plugin" "aws_efs" {
  plugin_id        = module.aws_efs_csi_plugin.plugin_id
  wait_for_healthy = true
}

resource "nomad_volume" "job_volume" {
  depends_on      = [ data.nomad_plugin.aws_efs ]
  type            = "csi"
  plugin_id       = "aws-efs"
  volume_id       = "nomad_job_volume"
  name            = "nomad_job_volume"
  external_id     = "${aws_efs_file_system.nomad.id}"
  access_mode     = "multi-node-multi-writer"
  attachment_mode = "file-system"
}