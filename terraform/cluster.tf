# >Discente: Lucas Cavalcante dos Santos | cavalcantesidi@outlook.com
# >Docente: Diego Luis Pires | dl.pires@sidi.org.br
# >Disciplina: Práticas de DevOps (Terraform)
# >Instituição: SiDi SOFTEX
# ---------------------------------------------------------------------------
# cluster.tf
# Cria o cluster k3d via null_resource + local-exec (não existe provider k3d
# nativo). Também gera o kubeconfig, faz docker build da app e importa a
# imagem direto no cluster (k3d image import).
#
# Destruir: provisioner "destroy" chama "k3d cluster delete".
# ---------------------------------------------------------------------------
resource "null_resource" "cluster" {
  triggers = {
    cluster_name = var.cluster_name
    server_count = var.server_count
    agent_count  = var.agent_count
    k3d_wait     = var.k3d_wait
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      set -e
      echo "==> Verificando se o cluster ${var.cluster_name} já existe"
      if k3d cluster list | grep -q "^${var.cluster_name} "; then
        echo "==> Cluster ${var.cluster_name} já existe, reutilizando."
      else
        echo "==> Criando cluster k3d '${var.cluster_name}'"
        k3d cluster create ${var.cluster_name} \
          --servers ${var.server_count} \
          --agents ${var.agent_count} \
          --wait=${var.k3d_wait} \
          -p ${var.app_port_host}:${var.app_nodeport}@server:0 \
          -p ${var.grafana_port_host}:${var.grafana_nodeport}@server:0
      fi

      echo "==> Gerando kubeconfig"
      k3d kubeconfig get ${var.cluster_name} > ${var.kubeconfig_path}

      echo "==> Build local da imagem task-manager:latest"
      docker build -t task-manager:latest ..

      echo "==> Importando imagem no cluster (k3d image import)"
      # O Docker Desktop/WSL2 pode retornar erro 500 intermitente no exec do
      # nó k3d mesmo com a imagem já transferida. Faz um retry e, ao final,
      # verifica (via crictl) se a imagem está realmente presente nos nós.
      for attempt in 1 2 3; do
        echo "==> Tentativa de import $${attempt}"
        if k3d image import task-manager:latest -c ${var.cluster_name}; then
          break
        else
          echo "!! Import falhou (tentativa $${attempt}), verificando imagem..."
        fi
      done

      for node in k3d-${var.cluster_name}-server-0 k3d-${var.cluster_name}-agent-0; do
        if ! docker exec "$node" crictl images | grep -q "task-manager:latest"; then
          echo "!! Imagem NAO presente no node $node (pod pode falhar com ErrImagePull)"
        else
          echo "==> Imagem presente no node $node"
        fi
      done

      echo "==> OK: cluster pronto"
    EOT
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["bash", "-c"]
    command     = "k3d cluster delete ${self.triggers.cluster_name} || true"
  }
}
