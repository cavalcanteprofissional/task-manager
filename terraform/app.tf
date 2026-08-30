# >Discente: Lucas Cavalcante dos Santos | cavalcantesidi@outlook.com
# >Docente: Diego Luis Pires | dl.pires@sidi.org.br
# >Disciplina: Práticas de DevOps (Terraform)
# >Instituição: SiDi SOFTEX
# ---------------------------------------------------------------------------
# app.tf
# Aplica os manifestos Kubernetes do task-manager (namespace, configmap,
# secret, postgres, app) via kubectl, usando o kubeconfig do cluster k3d.
# Depende do cluster (imagem já importada) e do banco (aplicado na sequência
# do diretório). Aguarda o rollout para garantir deploy saudável.
# ---------------------------------------------------------------------------
resource "null_resource" "app" {
  triggers = {
    cluster_name    = var.cluster_name
    kubeconfig_path = var.kubeconfig_path
  }

  depends_on = [null_resource.cluster]

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      set -e
      echo "==> Aplicando NAMESPACE primeiro (evita race do kubectl apply)"
      kubectl apply -f ../k8s/namespace.yaml --kubeconfig ${var.kubeconfig_path}

      echo "==> Aguardando namespace ficar Active"
      kubectl wait --for=jsonpath='{.status.phase}'=Active \
        namespace/${var.app_namespace} --kubeconfig ${var.kubeconfig_path} --timeout=60s

      echo "==> Aplicando demais manifests do task-manager (k8s/)"
      kubectl apply -f ../k8s/configmap.yaml \
                    -f ../k8s/secret.yaml \
                    -f ../k8s/postgres-deployment.yaml \
                    -f ../k8s/postgres-service.yaml \
                    -f ../k8s/deployment.yaml \
                    -f ../k8s/service.yaml \
                    --kubeconfig ${var.kubeconfig_path}

      echo "==> Aguardando rollout da aplicação"
      kubectl -n ${var.app_namespace} rollout status deploy/task-manager \
        --kubeconfig ${var.kubeconfig_path} --timeout=180s || true
    EOT
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["bash", "-c"]
    command     = "kubectl delete -f ../k8s/ --kubeconfig ${self.triggers.kubeconfig_path} --ignore-not-found || true"
  }
}
