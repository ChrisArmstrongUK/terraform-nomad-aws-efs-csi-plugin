# Example - EFS Volume for Jenkins

## NOTE

This example creates AWS resources which will incur a cost. Read the Terraform plan before deploying to check what resources will be created.

This example assumes you already have a Noamd cluster running in AWS. Hashicorp have a module in GitHub for this [HERE](https://github.com/hashicorp/terraform-aws-nomad) if you need one setup for testing.

## Deploying the example

Jenkins is a popular orchestration software which would require persistant storage to retain configuration. This example deploys the AWS EFS CSI plugin, creates a new EFS resource in AWS and registers the EFS volume on nomad. It will then deploy a jenkins service to Nomad that use the EFS volume to persist the jenkins workload.

1. Specify this example module in your Terraform code
2. Run `terraform init` to initialise the project. You may need to setup the [AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) and [Nomad](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs) Terraform providers dependung on your current setup.
3. Run `terraform plan` to check what will be created or changed.
4. If you're happy, to go ahead and run `terraform apply`
5. Check nomad to find the running allocation for jenkins and access it's http endpoint. This will send you to the Jenkins setup wizard. 
6. Quickly setup jenkins, you can find the admin password in the allocation logs. When you create a new user, remember the credentials you entered. Once you're logged in, make a job or two within jenkins, they don't need to do anything for this example.
7. Purge the nomad job by running `terraform destroy -target="nomad_job.jenkins"`
8. Check Nomad to ensure job has been purged
9.  Create the jenkins job again by running `terraform apply -target "nomad_job.jenkins"`
10. Check the http endpoint of the new Jenkins allocation. You should be able to login with the user you made and any jobs you created should have persisted.
11. Clear down after yourself by running `terraform destroy`