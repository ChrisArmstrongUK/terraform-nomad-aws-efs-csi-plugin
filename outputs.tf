output "plugin_id" {
  value       = var.plugin_id
  description = "The plugin id"
}

output "plugin_nodes_job_name" {
  value       = local.plugin_nodes_job_name
  description = "The name of the plugin nodes job"
}

output "plugin_nodes_jobspec" {
  value       = local.plugin_nodes_jobspec_rendered
  description = "The jobspec of the plugin nodes job"
}