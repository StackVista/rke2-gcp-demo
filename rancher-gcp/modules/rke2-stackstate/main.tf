resource "rancher2_app_v2" "stackstate-agent" {
  cluster_id = var.rke2_cluster_id
  name       = "stackstate-k8s-agent"
  namespace  = "stackstate"
  repo_name  = "rancher-partner-charts"
  chart_name = "stackstate-k8s-agent"
  values = templatefile("${path.module}/templates/agent-values.yaml", {
    sts_url          = var.sts_url
    sts_api_key      = var.sts_api_key
    sts_cluster_name = var.sts_cluster_name
  })
}
