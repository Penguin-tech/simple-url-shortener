resource "kubernetes_persistent_volume" "sqlite_pv" {
  metadata {
    name = "sqlite-pv"
  }

  spec {
    capacity = {
      storage = "1Gi"
    }

    storage_class_name = "manual"

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/mnt/data/sqlite"
      }
    }

    persistent_volume_reclaim_policy = "Retain"
  }
}


resource "kubernetes_persistent_volume_claim" "sqlite_pvc" {
  metadata {
    name      = "sqlite-pvc"
    namespace = kubernetes_namespace.url_shortener.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    storage_class_name = "manual"

    resources {
      requests = {
        storage = "1Gi"
      }
    }

    volume_name = kubernetes_persistent_volume.sqlite_pv.metadata[0].name
  }
}
