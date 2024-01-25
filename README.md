


# Initalize AWS infrastructure

### Infrastructure description

  * EC2 instances: 3 x EC2.medium (2 CPU, 8 GB RAM)
    * k8s-master
    * k8s-worker-1
    * k8s-worker-2
  * network objects
  * s3 bucket - needed for storing `kubeadm join` command
     
### Infrastructure precondition

For a successful infrastructure provisioning we need:
 
  * active AWS acount
  * `terraform` installed locally 


```bash
cd infrastructure-init
terraform init             # initialize backend - need to be called once
terraform plan             # optional
terraform apply            # create/upddate infrastructure

```
