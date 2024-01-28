


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
    * `ansible`
    * `istioctl`
    * `kubectl`

    ```bash
    cd infrastructure-init
    terraform init             # initialize backend - need to be called once
    terraform plan             # optional
    terraform apply            # create/upddate infrastructure

    ```

## Configure local `kubectl` to access AWS EKS cluster

1. Confugre credentials for `awscli`

    ```bash
    asw cofigure

    # std input:
    #access_key: AKIxxxxxxxxxxxxxxxxx
    #secret_key: h6V/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    ```

2. Exctract credentials from `awscli` to `kubectl` (file `/home/user/.kube/config` gets updated):

    ```bash
    aws eks update-kubeconfig --region <region> --name <cluster-name>
    # aws eks update-kubeconfig --region eu-central-1 --name education-eks-iCgeDNNU
    ```

## Application deployment repo

[istio-tryout-deployment](https://github.com/yulian-matev/istio-tryout-deployment)
