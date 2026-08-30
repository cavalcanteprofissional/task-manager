# >Discente: Lucas Cavalcante dos Santos | cavalcantesidi@outlook.com
# >Docente: Diego Luis Pires | dl.pires@sidi.org.br
# >Disciplina: Práticas de DevOps (Terraform)
# >Instituição: SiDi SOFTEX
# ---------------------------------------------------------------------------
# variables.tf
# Variáveis de configuração da solução (cluster k3d, portas, namespaces).
# ---------------------------------------------------------------------------
variable "cluster_name" {
  description = "Nome do cluster k3d gerenciado pelo Terraform"
  type        = string
  default     = "observabilidade"
}

variable "server_count" {
  description = "Quantidade de nós server (control-plane) do k3d"
  type        = number
  default     = 1
}

variable "agent_count" {
  description = "Quantidade de nós agent (worker) do k3d"
  type        = number
  default     = 1
}

variable "k3d_wait" {
  description = "Aguardar o cluster k3d ficar pronto (--wait)"
  type        = bool
  default     = true
}

variable "kubeconfig_path" {
  description = "Caminho do kubeconfig gerado (relativo ao diretório do Terraform)"
  type        = string
  default     = "./kubeconfig"
}

variable "app_namespace" {
  description = "Namespace da aplicação task-manager"
  type        = string
  default     = "task-manager"
}

variable "monitoring_namespace" {
  description = "Namespace da stack de observabilidade (Prometheus/Grafana/Loki)"
  type        = string
  default     = "monitoring"
}

# ---- Exposição externa (mapeamento host -> NodePort) -----------------------
variable "app_port_host" {
  description = "Porta no host para a aplicação task-manager"
  type        = number
  default     = 3000
}

variable "app_nodeport" {
  description = "NodePort do Service da aplicação"
  type        = number
  default     = 30010
}

variable "grafana_port_host" {
  description = "Porta no host para o Grafana"
  type        = number
  default     = 3001
}

variable "grafana_nodeport" {
  description = "NodePort do Service do Grafana"
  type        = number
  default     = 30009
}
