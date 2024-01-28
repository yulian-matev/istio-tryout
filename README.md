
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

## Overview

```bash
    GitHub
                  on pull request OK:
                    * gen Docker images
  +------------+    * gen deployment     +-----------+
  |  src_repo  | ----.     .-----------> | depl_repo |
  +------------+      \   /              +-----------+
                       \ /                 ^
                        V                  |
                    +-----------+          |
                    | Dockerhub |          |
                    |  repo     |          |
                    +-----------+          |
                                           |
    AWS                                    | monitor for changes
                                           |
   +---------------------------------------|--------+
   |    Kubernetes (AWS EKS)               |        |
   |                                  +--------+    |
   |        +-------------------------| ArgoCD |    |
   |        |     deploy              +--------+    |
   |        V                                       |
   |  +-----------+                                 |
   |  |  my app   |                                 |
   |  +-----------+                                 |
   +------------------------------------------------+

```

## Application deployment repo

[istio-tryout-deployment](https://github.com/yulian-matev/istio-tryout-deployment)



## Verify configuration

Following pods and services should be available:

```bash

# kubectl get pods,svc -A

NAMESPACE      NAME                                                   READY   STATUS    RESTARTS   AGE
argocd         pod/argocd-application-controller-0                    1/1     Running   0          16m
argocd         pod/argocd-applicationset-controller-dc5c4c965-vbpx2   1/1     Running   0          16m
argocd         pod/argocd-dex-server-9769d6499-vs7sr                  1/1     Running   0          16m
argocd         pod/argocd-notifications-controller-db4f975f8-pk2vp    1/1     Running   0          16m
argocd         pod/argocd-redis-b5d6bf5f5-lckwp                       1/1     Running   0          16m
argocd         pod/argocd-repo-server-579cdc7849-f89vq                1/1     Running   0          16m
argocd         pod/argocd-server-557c4c6dff-pk9ds                     1/1     Running   0          16m
istio-system   pod/grafana-5f9b8c6c5d-jsqvn                           1/1     Running   0          10m
istio-system   pod/istio-egressgateway-975ff4944-788gt                1/1     Running   0          10m
istio-system   pod/istio-ingressgateway-6cb9989d98-8z5xn              1/1     Running   0          10m
istio-system   pod/istiod-855f4b5f7-qlm8k                             1/1     Running   0          11m
istio-system   pod/jaeger-db6bdfcb4-wg95p                             1/1     Running   0          10m
istio-system   pod/kiali-cc67f8648-zdsbl                              1/1     Running   0          10m
istio-system   pod/prometheus-5d5d6d6fc-lpq68                         2/2     Running   0          10m
kube-system    pod/aws-node-fzcdz                                     2/2     Running   0          65m
kube-system    pod/aws-node-nzglg                                     2/2     Running   0          64m
kube-system    pod/coredns-6566899dc6-cljpq                           1/1     Running   0          67m
kube-system    pod/coredns-6566899dc6-jmq8m                           1/1     Running   0          67m
kube-system    pod/ebs-csi-controller-b5bd9b84-lrpx5                  6/6     Running   0          66m
kube-system    pod/ebs-csi-controller-b5bd9b84-m9zfc                  6/6     Running   0          66m
kube-system    pod/ebs-csi-node-b6g9h                                 3/3     Running   0          64m
kube-system    pod/ebs-csi-node-hjv9x                                 3/3     Running   0          65m
kube-system    pod/kube-proxy-r4nrv                                   1/1     Running   0          64m
kube-system    pod/kube-proxy-wdfmr                                   1/1     Running   0          65m

NAMESPACE      NAME                                              TYPE           CLUSTER-IP       EXTERNAL-IP                                                                  PORT(S)                                                                      AGE
argocd         service/argocd-applicationset-controller          ClusterIP      172.20.177.249   <none>                                                                       7000/TCP,8080/TCP                                                            17m
argocd         service/argocd-dex-server                         ClusterIP      172.20.32.122    <none>                                                                       5556/TCP,5557/TCP,5558/TCP                                                   17m
argocd         service/argocd-metrics                            ClusterIP      172.20.102.159   <none>                                                                       8082/TCP                                                                     16m
argocd         service/argocd-notifications-controller-metrics   ClusterIP      172.20.15.187    <none>                                                                       9001/TCP                                                                     16m
argocd         service/argocd-redis                              ClusterIP      172.20.83.243    <none>                                                                       6379/TCP                                                                     16m
argocd         service/argocd-repo-server                        ClusterIP      172.20.90.144    <none>                                                                       8081/TCP,8084/TCP                                                            16m
argocd         service/argocd-server                             ClusterIP      172.20.71.51     <none>                                                                       80/TCP,443/TCP                                                               16m
argocd         service/argocd-server-metrics                     ClusterIP      172.20.92.101    <none>                                                                       8083/TCP                                                                     16m
default        service/kubernetes                                ClusterIP      172.20.0.1       <none>                                                                       443/TCP                                                                      70m
istio-system   service/grafana                                   ClusterIP      172.20.165.132   <none>                                                                       3000/TCP                                                                     10m
istio-system   service/istio-egressgateway                       ClusterIP      172.20.73.171    <none>                                                                       80/TCP,443/TCP                                                               10m
istio-system   service/istio-ingressgateway                      LoadBalancer   172.20.145.17    ab0b424a5489d4dd48c77b34a83362e8-1038563620.eu-central-1.elb.amazonaws.com   15021:31259/TCP,80:32018/TCP,443:30892/TCP,31400:31639/TCP,15443:30040/TCP   10m
istio-system   service/istiod                                    ClusterIP      172.20.197.5     <none>                                                                       15010/TCP,15012/TCP,443/TCP,15014/TCP                                        11m
istio-system   service/jaeger-collector                          ClusterIP      172.20.128.90    <none>                                                                       14268/TCP,14250/TCP,9411/TCP,4317/TCP,4318/TCP                               10m
istio-system   service/kiali                                     ClusterIP      172.20.248.154   <none>                                                                       20001/TCP,9090/TCP                                                           10m
istio-system   service/prometheus                                ClusterIP      172.20.187.35    <none>                                                                       9090/TCP                                                                     10m
istio-system   service/tracing                                   ClusterIP      172.20.129.75    <none>                                                                       80/TCP,16685/TCP                                                             10m
istio-system   service/zipkin                                    ClusterIP      172.20.105.80    <none>                                                                       9411/TCP                                                                     10m
kube-system    service/kube-dns                                  ClusterIP      172.20.0.10      <none>                                                                       53/UDP,53/TCP                                                                67m
```


Access ArgoCD's web interface: `kubectl port-forward svc/argocd-server -n argocd 8080:443`




Observability Add-ons
```
# Visualize Istio Mesh console using Kiali
kubectl port-forward svc/kiali 20001:20001 -n istio-system

# Get to the Prometheus UI
kubectl port-forward svc/prometheus 9090:9090 -n istio-system

# Visualize metrics in using Grafana
kubectl port-forward svc/grafana 3000:3000 -n istio-system

# Visualize application traces via Jaeger
kubectl port-forward svc/jaeger 16686:16686 -n istio-system
```
