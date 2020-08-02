locals {
  plugin_nodes_job_name = var.plugin_nodes_job_name_override != null ? var.plugin_nodes_job_name_override : "plugin-csi-nodes-${var.plugin_id}"
  plugin_nodes_jobspec_variables = {
    job_name             = local.plugin_nodes_job_name
    region               = var.nomad_region
    datacenters          = var.nomad_datacenters
    plugin_id            = var.plugin_id
    plugin_csi_mount_dir = var.plugin_csi_mount_dir
    plugin_cpu           = var.plugin_nodes_job_cpu
    plugin_memory        = var.plugin_nodes_job_memory
    plugin_image         = "amazon/aws-efs-csi-driver"
    plugin_image_version = var.plugin_nodes_job_image_version
  }
  plugin_nodes_jobspec_rendered = templatefile("${path.module}/templates/csi-plugin-nodes.nomad.hcl.tpl", local.plugin_nodes_jobspec_variables)
}

resource "nomad_job" "plugin-csi-nodes" {
  jobspec                 = local.plugin_nodes_jobspec_rendered
  deregister_on_destroy   = var.deregister_on_destroy
  deregister_on_id_change = var.deregister_on_id_change
  detach                  = var.detach
  policy_override         = var.policy_override
  json                    = false
}