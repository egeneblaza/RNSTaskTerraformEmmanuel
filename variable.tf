variable "project" {}

variable "region" {
  default = "us-central1"
}

variable "region2" {
  default = "us-east1"
}

variable "zone" {
  default = "us-central1-c"
}

variable "zone2" {
  default = "us-east2"
}

variable "db-instance-name" {
  default = "task-db-instance"
}

variable "db-instance-tier" {
  default = "db-f1-micro"
}

variable "db-name" {
  default = "task-db"
}

variable "database_version" {
  default = "MYSQL_8_0"
}

variable "db_user_name" {
  type = string
}

variable "db_user_password" {
  type      = string
  sensitive = true
}

variable "db_user_host" {
  type    = string
  default = "%"
}


variable "cloudrun_service_name" {
  default = "task-cloud-run-service-name"
}

variable "cloudrun_service_name2" {
  default = "task-cloud-run-service-name-2"
}

variable "network_endpoint_type" {
  default = "SERVERLESS"
}

variable "neg_name_1" {
  default = "task-neg-cloud-run-1"
}

variable "neg_name_2" {
  default = "task-neg-cloud-run-2"
}

variable "cloudrun_backend_name" {
  default = "task-be-cloud-run"
}

variable "url_map_name" {
  default = "task-url-map-name"
}

variable "http_proxy_name" {
  default = "task-http-proxy-name"
}

variable "lb_ip_name" {
  default = "task-lb-ip-name"
}

variable "http_forwarding_rule_name" {
  default = "task-http-forwarding-rule-name"
}