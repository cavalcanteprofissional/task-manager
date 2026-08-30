# >Discente: Lucas Cavalcante dos Santos | cavalcantesidi@outlook.com
# >Docente: Diego Luis Pires | dl.pires@sidi.org.br
# >Disciplina: Práticas de DevOps (Terraform)
# >Instituição: SiDi SOFTEX
# ---------------------------------------------------------------------------
# dashboards.tf
# Aplica o ConfigMap do dashboard Grafana (métricas + logs) no namespace
# "monitoring", APÓS os charts estarem instalados (garante que o namespace
# exista). O sidecar de dashboards do kube-prometheus-stack provisiona
# automaticamente (label grafana_dashboard).
# ---------------------------------------------------------------------------
resource "null_resource" "dashboard" {
  triggers = {
    kubeconfig_path = var.kubeconfig_path
  }

  depends_on = [
    helm_release.kube_prometheus_stack,
    helm_release.loki_stack,
  ]

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      set -e
      echo "==> Aplicando dashboard Grafana (dashboards/)"
      kubectl apply -f ../dashboards/ --kubeconfig ${var.kubeconfig_path}
    EOT
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["bash", "-c"]
    command     = "kubectl delete -f ../dashboards/ --kubeconfig ${self.triggers.kubeconfig_path} --ignore-not-found || true"
  }
}
