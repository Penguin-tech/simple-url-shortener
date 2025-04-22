# terraform {
#  backend "remote" {
#    organization = "Paul-Le-Dev-Org"
#
#    workspaces {
#      name = "simple-url-shortener"
#    }
#  }
#}

provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "minikube"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config" 
    config_context = "minikube"
  }
}


resource "kubernetes_namespace" "url_shortener" {
  metadata {
    name = "url-shortener"
  }
}

# resource "kubernetes_deployment" "url_shortener" {
#   metadata {
#     name      = "url-shortener"
#     namespace = kubernetes_namespace.url_shortener.metadata[0].name
#   }

#   spec {
#     replicas = 1

#     selector {
#       match_labels = {
#         url_shortener = "url-shortener"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           url_shortener = "url-shortener"
#         }
#       }

#       spec {
#         container {
#           image = "paulledev/url-shortener:latest"
#           name  = "url-shortener"
#           port {
#             container_port = 5000
#           }
#         }

#         image_pull_secrets {
#           name = kubernetes_secret.docker_registry.metadata[0].name
#         }

#       }
#     }
#   }
# }

# resource "kubernetes_service" "url_shortener" {
#   metadata {
#     name      = "url-shortener-service"
#     namespace = kubernetes_namespace.url_shortener.metadata[0].name
#   }

#   spec {
#     selector = {
#       url_shortener = "url-shortener"
#     }

#     port {
#       port        = 80
#       target_port = 5000
#     }

#     type = "NodePort"
#   }
# }

resource "helm_release" "url_shortener" {
  name       = "url-shortener"
  chart      = "../url-shortener-helm" 
  namespace = "url-shortener"

  values = [
    # Optionally override values in values.yaml (can also pass dynamic variables here)
    <<EOF
    image:
      repository: "paulledev/url-shortener"
      tag: "latest"
    imagePullSecrets:
      - name: "docker-registry-secret"
    EOF
  ]

  depends_on = [kubernetes_namespace.url_shortener]
}
