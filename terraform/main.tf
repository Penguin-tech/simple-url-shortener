//terraform {
//  backend "remote" {
//    organization = "Paul-Le-Dev-Org"
//
//    workspaces {
//      name = "simple-url-shortener"
//    }
//  }
//}

provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "minikube"
}

resource "kubernetes_namespace" "app_url_shortener" {
  metadata {
    name = "url-shortener"
  }
}

resource "kubernetes_deployment" "app_url_shortener" {
  metadata {
    name      = "url-shortener"
    namespace = kubernetes_namespace.app_url_shortener.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app_url_shortener = "url-shortener"
      }
    }

    template {
      metadata {
        labels = {
          app_url_shortener = "url-shortener"
        }
      }

      spec {
        container {
          image = "paulledev/url-shortener:latest"
          name  = "url-shortener"
          port {
            container_port = 5000
          }
        }

        image_pull_secrets {
          name = kubernetes_secret.docker_registry.metadata[0].name
        }

      }
    }
  }
}

resource "kubernetes_service" "app_url_shortener" {
  metadata {
    name      = "url-shortener-service"
    namespace = kubernetes_namespace.app_url_shortener.metadata[0].name
  }

  spec {
    selector = {
      app_url_shortener = "url-shortener"
    }

    port {
      port        = 80
      target_port = 5000
    }

    type = "NodePort"
  }
}
