output "efs_id" {
  value       = aws_efs_file_system.nomad.id
  description = "The ID of the EFS resource"
}

output "nomad_jenkins_job_name" {
  value       = local.jenkins_job_name
  description = "The name of the Nomad jenkins job"
}