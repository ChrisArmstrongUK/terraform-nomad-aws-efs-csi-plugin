variable "nomad_region" {
  type        = string
  default     = "global"
  description = "The Nomad region to run the plugin nodes in"
}

variable "nomad_datacenters" {
  type        = list(string)
  default     = ["dc1"]
  description = "The Nomad datacenters to run the plugin nodes in"
}

variable "plugin_id" {
  type        = string
  default     = "aws-efs"
  description = "The ID of the Nomad CSI plugin"
}

variable "plugin_csi_mount_dir" {
  type        = string
  default     = "/csi"
  description = "The CSI mount directroy the Nomad agents"
}

variable "plugin_nodes_job_name_override" {
  type        = string
  default     = ""
  description = "The job name for the plugin's nodes job. If not specified this will default to plugin-csi-nodes-[csi_plugin_id]"
}

variable "plugin_nodes_job_cpu" {
  type        = number
  default     = 100
  description = "The CPU allocated to the plugin nodes task"
}

variable "plugin_nodes_job_memory" {
  type        = number
  default     = 126
  description = "The memory allocated to the plugin nodes task"
}

variable "plugin_nodes_job_image_version" {
  type        = string
  default     = "v1.0.0"
  description = "The image version of the AWS EFS CSI driver (https://github.com/kubernetes-sigs/aws-efs-csi-driver/packages/30694)"
}

variable "deregister_on_destroy" {
  type        = bool
  default     = true
  description = "Determines if the plugin jobs will be deregistered when destroyed"
}

variable "deregister_on_id_change" {
  type        = bool
  default     = true
  description = "Determines if the plugin jobs will be deregistered when the jobspec ID changes"
}

variable "detach" {
  type        = bool
  default     = false
  description = "If true, the provider will return immediately after creating or updating nomad jobs, instead of monitoring"
}

variable "policy_override" {
  type        = bool
  default     = false
  description = "Determines if the job will override any soft-mandatory Sentinel policies and register even if they fail."
}