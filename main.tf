locals {
  plugin_node_job_name = var.plugin_node_job_name_override != "" ? var.plugin_node_job_name_override : "csi-plugin-nodes-${var.plugin_id}"
  plugin_node_jobspec_variables = {
    job_name             = local.plugin_node_job_name
    region               = var.nomad_region
    datacenters          = var.nomad_datacenters
    plugin_id            = var.plugin_id
    plugin_csi_mount_dir = var.plugin_csi_mount_dir
    plugin_cpu           = var.plugin_node_job_cpu
    plugin_memory        = var.plugin_node_job_memory
    plugin_image         = "amazon/aws-efs-csi-driver"
    plugin_image_version = var.plugin_driver_image_version
  }
  plugin_node_jobspec_rendered = templatefile("${path.module}/templates/csi-plugin-node.nomad.hcl.tpl", local.plugin_node_jobspec_variables)
}

resource "nomad_job" "aws_efs_csi_plugin_nodes" {
  jobspec                 = local.plugin_node_jobspec_rendered
  deregister_on_destroy   = var.deregister_on_destroy
  deregister_on_id_change = var.deregister_on_id_change
  detach                  = var.detach
  policy_override         = var.policy_override
  json                    = false
}