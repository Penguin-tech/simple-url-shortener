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

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
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
  cleanup_on_fail  = true

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

resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  namespace  = "monitoring"
  depends_on = [kubernetes_namespace.monitoring]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitoring"
  depends_on = [kubernetes_namespace.monitoring]
}

resource "helm_release" "promtail" {
  name       = "promtail"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  namespace  = "monitoring"
  depends_on = [kubernetes_namespace.monitoring]

  #not using lokigateway
  set {
    name  = "config.clients[0].url"
    value = "http://10.106.122.205:3100/loki/api/v1/push"
  }
}