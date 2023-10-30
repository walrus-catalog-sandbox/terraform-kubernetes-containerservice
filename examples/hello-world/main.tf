terraform {
  required_version = ">= 1.0"
}

module "this" {
  source = "../.."

  context = {
    project = {
      "name" = "project_name"
      "id"   = "project_id"
    }
    environment = {
      "name" = "environment_name"
      "id"   = "environment_id"
    }
    service = {
      "name" = "service_name"
      "id"   = "service_id"
    }
  }
}

output "project_name" {
  value = module.this.walrus_project_name
}

output "environment_name" {
  value = module.this.walrus_environment_name
}

output "service_name" {
  value = module.this.walrus_service_name
}
