resource "google_cloud_run_service" "cloudrun_service_name" {
  name     = var.cloudrun_service_name
  location = var.region

  traffic {
    latest_revision = true
    percent         = 100
  }
  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
        # Pass environment variables for DB connection
        env {
          name  = "DB_HOST"
          value = "/cloudsql/${google_sql_database_instance.instance.name}"
        }
        env {
          name  = "DB_USER"
          value = var.db_user_name
        }
        env {
          name  = "DB_PASSWORD"
          value = var.db_user_password
        }
        env {
          name  = "DB_NAME"
          value = google_sql_database.database.name # Reference database name
        }
        resources {
          limits = {
            memory = "256Mi" # Free tier limit: 256Mi for memory
            cpu    = "0.5"   # Free tier limit: 0.5 vCPU
          }
        }
      }
    }
    metadata {
      annotations = {
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.instance.connection_name
      }

    }
  }
}

resource "google_cloud_run_service_iam_member" "allow_public" {
  service  = google_cloud_run_service.cloudrun_service_name.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}


resource "google_compute_region_network_endpoint_group" "neg_1" {
  name                  = var.neg_name_1
  network_endpoint_type = var.network_endpoint_type
  region                = var.region
  cloud_run {
    service = google_cloud_run_service.cloudrun_service_name.name
  }
}

resource "google_cloud_run_service" "cloudrun_service_name2" {
  name     = var.cloudrun_service_name2
  location = var.region2
  traffic {
    latest_revision = true
    percent         = 100
  }
  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
        # Pass environment variables for DB connection
        env {
          name  = "DB_HOST"
          value = "/cloudsql/${google_sql_database_instance.instance.name}"
        }
        env {
          name  = "DB_USER"
          value = var.db_user_name
        }
        env {
          name  = "DB_PASSWORD"
          value = var.db_user_password
        }
        env {
          name  = "DB_NAME"
          value = google_sql_database.database.name # Reference database name
        }
        resources {
          limits = {
            memory = "256Mi" # Free tier limit: 256Mi for memory
            cpu    = "0.5"   # Free tier limit: 0.5 vCPU
          }
        }
      }
    }
    metadata {
      annotations = {
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.instance.connection_name
      }
    }
  }
}

resource "google_cloud_run_service_iam_member" "allow_public2" {
  service  = google_cloud_run_service.cloudrun_service_name2.name
  location = var.region2
  role     = "roles/run.invoker"
  member   = "allUsers"
}



resource "google_compute_region_network_endpoint_group" "neg_2" {
  name                  = var.neg_name_2
  network_endpoint_type = var.network_endpoint_type
  region                = var.region2
  cloud_run {
    service = google_cloud_run_service.cloudrun_service_name2.name
  }
}

resource "google_compute_backend_service" "cloudrun_backend" {
  name                            = var.cloudrun_backend_name
  protocol                        = "HTTP"
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  port_name                       = "http"
  timeout_sec                     = 30
  connection_draining_timeout_sec = 0
  enable_cdn                      = false

  backend {
    group           = google_compute_region_network_endpoint_group.neg_1.id
    balancing_mode  = "UTILIZATION"
    max_utilization = 1.0
    capacity_scaler = 1.0
  }

  backend {
    group           = google_compute_region_network_endpoint_group.neg_2.id
    balancing_mode  = "UTILIZATION"
    max_utilization = 1.0
    capacity_scaler = 1.0
  }

}

resource "google_compute_url_map" "url_map" {
  name            = var.url_map_name
  default_service = google_compute_backend_service.cloudrun_backend.id
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = var.http_proxy_name
  url_map = google_compute_url_map.url_map.id
}

resource "google_compute_global_address" "lb_ip" {
  name = var.lb_ip_name
}

resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name                  = var.http_forwarding_rule_name
  ip_address            = google_compute_global_address.lb_ip.id
  port_range            = "80"
  target                = google_compute_target_http_proxy.http_proxy.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}