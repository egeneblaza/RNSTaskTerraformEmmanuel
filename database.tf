resource "google_sql_database_instance" "instance" {
  name             = var.db-instance-name
  region           = var.region
  database_version = var.database_version
  settings {
    tier = var.db-instance-tier
  }
  deletion_protection = false
  project             = var.project
}

resource "google_sql_user" "users" {
  name     = var.db_user_name
  instance = google_sql_database_instance.instance.name
  host     = var.db_user_host
  password = var.db_user_password
  project  = var.project
}

resource "google_sql_database" "database" {
  name     = var.db-name
  instance = google_sql_database_instance.instance.name
  project  = var.project
}

