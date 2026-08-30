# >Discente: Lucas Cavalcante dos Santos | cavalcantesidi@outlook.com
# >Docente: Diego Luis Pires | dl.pires@sidi.org.br
# >Disciplina: Práticas de DevOps (Terraform)
# >Instituição: SiDi SOFTEX
# ---------------------------------------------------------------------------
# outputs.tf
# Informações úteis pós-apply: acessos, comandos de validação e limpeza.
# ---------------------------------------------------------------------------
output "cluster_name" {
  description = "Nome do cluster k3d gerenciado pelo Terraform"
  value       = var.cluster_name
}

output "kubeconfig" {
  description = "Caminho do kubeconfig gerado (use em kubectl/helm)"
  value       = var.kubeconfig_path
}

output "app_url" {
  description = "URL da aplicação task-manager"
  value       = "http://localhost:${var.app_port_host}"
}

output "grafana_url" {
  description = "URL do Grafana (login admin/prom-operator)"
  value       = "http://localhost:${var.grafana_port_host}"
}

output "grafana_login" {
  description = "Credenciais padrão do Grafana"
  value       = { user = "admin", password = "prom-operator" }
}

output "acessos_uteis" {
  description = "Comandos úteis de validação"
  value       = <<-EOT
    # Pods da aplicação
    kubectl -n ${var.app_namespace} get pods --kubeconfig ${var.kubeconfig_path}
    # Charts Helm (monitoring)
    helm list -n ${var.monitoring_namespace} --kubeconfig ${var.kubeconfig_path}
    # Prometheus (métricas) via port-forward
    kubectl -n ${var.monitoring_namespace} port-forward svc/kube-prometheus-stack-prometheus 9090:9090 --kubeconfig ${var.kubeconfig_path}
    # Loki (logs) via port-forward
    kubectl -n ${var.monitoring_namespace} port-forward svc/loki 3100:3100 --kubeconfig ${var.kubeconfig_path}
  EOT
}
