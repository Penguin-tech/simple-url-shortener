resource "kubernetes_secret" "docker_registry" {
  metadata {
    name = "docker-registry-secret"
    namespace = kubernetes_namespace.url_shortener.metadata[0].name
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "https://index.docker.io/v1/" = {
          username = var.DOCKER_USERNAME
          password = var.DOCKER_PASSWORD
          auth     = base64encode("${var.DOCKER_USERNAME}:${var.DOCKER_PASSWORD}")
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"

  depends_on = [kubernetes_namespace.url_shortener]
}
