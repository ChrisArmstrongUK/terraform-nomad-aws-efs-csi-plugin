![Terraform Validate](https://github.com/KristophUK/terraform-nomad-aws-efs-csi-plugin/workflows/Terraform%20Validate/badge.svg?branch=master)

# terraform-nomad-aws-efs-csi-plugin

This module deploys the AWS EFS driver into Nomad to allow job allocations to use AWS EFS volumes.

- [Nomad Storage Plugins](https://www.nomadproject.io/docs/internals/plugins/csi)
- [AWS EFS CSI Driver GitHub Page](https://github.com/kubernetes-sigs/aws-efs-csi-driver)

## Note before use

This plugin leverages ec2 metadata to function so can only be deployed to nomad cluster running on AWS EC2. See the AWS EFS CSI Driver GitHub Page for information.

## Registering an EFS Volume

Once the plugin has deployed successfully you can register an EFS Volume. Create a volume config file such as the one below...

efs-volume.hcl
```hcl
id = "efs1"
name = "efs1"
type = "csi"
external_id = [EFSFileSystemId]:[EFSSubPath]:[EFSAccessPointId]
plugin_id = "aws-efs"
access_mode = "multi-nodes-multi-writer"
attachment_mode = "file-system"
```
Where...
- EFSFileSystemId = The ID of the EFS volume.
- EFSSubPath = (Not Required) The sub path to mount. This can be left blank if you are using the root directory. 
- EFSAccessPointId = (Not Required) The ID of the EFS access point.

Then register the volume...
```shell
nomad volume register efs-volume.hcl
```
---
or register the volume using Terraform and the Nomad Provider...
```hcl
module "nomad_aws_efs_csi_plugin" {
  source = "[nomad_aws_efs_csi_plugin_source]"
}

data "nomad_plugin" "aws_efs" {
  plugin_id              = module.nomad_efs_csi_plugin.plugin_id
  wait_for_healthy       = true
  wait_for_registeration =  true
}

resource "nomad_volume" "efs_0" {
  type                  = "csi"
  plugin_id             = data.nomad_plugin.aws_efs.id
  volume_id             = "efs_0"
  name                  = "efs_0"
  external_id           = [EFSFileSystemId]:[EFSSubPath]:[EFSAccessPointId]
  access_mode           = "multi-nodes-multi-writer"
  attachment_mode       = "file-system"
}
```