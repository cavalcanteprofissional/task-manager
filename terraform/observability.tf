# >Discente: Lucas Cavalcante dos Santos | cavalcantesidi@outlook.com
# >Docente: Diego Luis Pires | dl.pires@sidi.org.br
# >Disciplina: Práticas de DevOps (Terraform)
# >Instituição: SiDi SOFTEX
# ---------------------------------------------------------------------------
# observability.tf
# Instala a stack de observabilidade via Helm (provider hashicorp/helm):
#   - kube-prometheus-stack: Prometheus + Grafana + Alertmanager + CRDs
#   - loki-stack: Loki + Promtail (logs), grafana desabilitado (usa o do
#     kube-prometheus-stack), datasource Loki provisionado no Grafana.
# ---------------------------------------------------------------------------
resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = var.monitoring_namespace
  create_namespace = true

  values = [
    file("${path.module}/values/kube-prometheus-stack.yaml")
  ]

  depends_on = [null_resource.cluster]
}

resource "helm_release" "loki_stack" {
  name             = "loki-stack"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki-stack"
  namespace        = var.monitoring_namespace
  create_namespace = false

  values = [
    file("${path.module}/values/loki-stack.yaml")
  ]

  depends_on = [
    helm_release.kube_prometheus_stack,
    null_resource.cluster,
  ]
}
