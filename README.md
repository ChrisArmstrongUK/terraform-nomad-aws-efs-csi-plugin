![Terraform Validate](https://github.com/KristophUK/terraform-nomad-aws-efs-csi-plugin/workflows/Terraform%20Validate/badge.svg?branch=master)

# Terraform Module - AWS EFS CSI Plugin

AWS EFS is a managed NFS file system provided as a service by AWS. This module deploys the AWS EFS CSI Plugin into Nomad to allow Nomad jobs to use AWS EFS volumes as persistant storage for stateful workloads or for sharing files amoungst different jobs/tasks.

## Links

- [Nomad Storage Plugins - CSI Plugins](https://www.nomadproject.io/docs/internals/plugins/csi#csi-plugins)
- [AWS EFS - Product Page](https://aws.amazon.com/efs/)
- [AWS EFS CSI Driver - GitHub Repository](https://github.com/kubernetes-sigs/aws-efs-csi-driver)
- [AWS EFS CSI Driver - AWS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html)

## Note before use

The CSI itself can be found on the [AWS EFS CSI Driver GitHub Page](https://github.com/kubernetes-sigs/aws-efs-csi-driver). It's a good place to look for documentation, features and issues. Most of the documentation on the GitHub page at the moment assumes you're using Kubernetes but the CSI itself should be cross compatible with any container orchestrator that supports CSI. (Which includes Nomad).

I believe currently this plugin leverages ec2 metadata to function, so can only be deployed on Nomad agents running on AWS EC2 instances. EFS can normally be mounted outside of ec2 so this may change in the future.

## Deploying the plugin to Nomad

### Privileged Containers

The nomad agents and docker daemon must be configured to allow privileged containers. Make sure you understand what this means before proceeding and check the docker image being run as part of this job.

nomad config snippet...
```HCL
client {
    enabled = true
    options {
        "docker.privileged.enabled" = "true"
    }
}
```

### Deployment the CSI Plugin

See provision instructions on the [Terraform Registry page](https://registry.terraform.io/modules/KristophUK/aws-efs-csi-plugin/nomad/)

## Registering an EFS Volume

Once the plugin has deployed successfully you can register an EFS Volume. Create a volume config file such as the one below. I have written some examples of what values can be used for `external_id` in "[EFS Access Points and Subpaths](https://github.com/KristophUK/terraform-nomad-aws-efs-csi-plugin#efs-access-points-and-subpaths)"

---
efs-volume.hcl
```HCL
id = "efs0"
name = "efs0"
type = "csi"
external_id = [EFSFileSystemId]:[EFSSubPath]:[EFSAccessPointId]
plugin_id = "aws-efs"
access_mode = "multi-node-multi-writer"
attachment_mode = "file-system"
```
---
Then register the volume...
```shell
nomad volume register efs-volume.hcl
```
---
You can also register the volume using Terraform and the Nomad Provider. See the module examples.

## EFS Access Points and Subpaths

`external_id` in the volume config supports the various combinations of the pattern `[EFSFileSystemId]:[EFSSubPath]:[EFSAccessPointId]`.

- `external_id = "fs-12345678"` (The EFS volume from the root directory)
- `external_id = "fs-12345678:/images"` (The EFS volume using the subpath /images. This subpath should already exist on the EFS volume)
- `external_id = "fs-12345678::fsap-12345678"` (The EFS volume with an associated EFS access point)
- `external_id = "fs-12345678:/lemurs:fsap-12345678"` (The EFS volume with an associated EFS access point using subpath /lemurs in context to the root configured on the access point. For example, if the root directory of the access point was configured to `/images`. This subpath would be equivalent to `/images/lemurs`)

## Using the volume

Once the volume has been registered it can be used in a jobspec. For this example, assume a volume has already been registered with the id `jenkins_efs`. You could then run this job and setup Jenkins, maybe creating a job or two. If you then purge and re-create the jenkins job, you should see all the config changes and jobs you created have persisted.

```HCL
job "jenkins" {
  datacenters = ["dc1"]
  type        = "service"

  group "jenkins" {
    count = 1

    volume "jenkins_home" {
      type      = "csi"
      read_only = false
      source    = "jenkins_efs"
    }

    task "jenkins" {
      driver = "docker"

      volume_mount {
        volume      = "jenkins_home"
        destination = "/var/jenkins_home"
        read_only   = false
      }

      config {
        image = "jenkins/jenkins:latest"

        port_map {
          http = 8080
          jnlp = 50000
        }
      }

      resources {
        cpu    = 500
        memory = 512
        network {
          port "http" {}
          port "jnlp" {}
        }
      }

      service {
        name = "jenkins"
        port = "http"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
```