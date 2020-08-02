variable "nomad_datacenters" {
  type        = list(string)
  default     = ["dc1"]
  description = "The Nomad datacenters to run the plugin nodes in"
}