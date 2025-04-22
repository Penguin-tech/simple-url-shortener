resource "kubernetes_secret" "docker_registry" {
  metadata {
    name = "docker-registry-secret"
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
}