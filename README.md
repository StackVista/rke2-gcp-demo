# RKE2 HA Cluster Setup

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads?product_intent=terraform)
- [Google SDK](https://cloud.google.com/sdk/docs/install)
- [Taskfile](https://taskfile.dev/)

## Setup the cluster

### Setup environment variables

Setup a `gcp.tfvars` file for configuring the env.

```
gcp_project="<GCP PROJECT>"
gcp_region="<GCP REGION>" # optional, default is europe-west4
gcp_zone="<GCP ZONE>" # optional, default is europe-west4-a
username="<SSH USERNAME>"
iam_user="<GOOGLE ACCOUNT>"
home_ips=["<YOUR HOME IP1>", "<YOUR HOME IP2>", ...]
sts_api_key="<API KEY>"
sts_url="<STS URL>"
```

### Provision Cluster

```bash
task terraform-init
task terraform-apply
task terraform-output
```
Now wait a few minutes, the cloud-init script will take a while to complete after the cluster has been provisioned and Terraform is done.

### Setup local kubeconfig

```bash
task all-kubeconfig
```

This command will install a context for each provisioned cluster.

### Checking it all works:

```bash
task check-cluster-connection CLUSTER=<CLUSTER NAME>
```
Check that your setup worked. If all went well you should see,

```bash
❯ task check-cluster-connection CLUSTER=rke2-cluster-0
task: [check-cluster-connection] kubectl --context rke2-cluster-0 get nodes
NAME                      STATUS   ROLES                       AGE    VERSION
rke2-cluster-0-agent-0    Ready    <none>                      102m   v1.26.9+rke2r1
rke2-cluster-0-master-0   Ready    control-plane,etcd,master   102m   v1.26.9+rke2r1
```

## Working with the cluster

### Stopping and Starting the cluster

TODO

### Install the demo app

Ensure you've run the `task terraform-output` command so that the `.provisioned_env` file is up-to-date. After that execute the following:

```bash
> task deploy-sock-shop
```

This will deploy the sock-shop over the 2 clusters with ingresses setup.

## Destroy the cluster

Run `task terraform-destroy`
