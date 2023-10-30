#
# Contextual output
#

output "walrus_project_name" {
  value       = try(local.context["project"]["name"], null)
  description = "The name of project where deployed in Walrus."
}

output "walrus_project_id" {
  value       = try(local.context["project"]["id"], null)
  description = "The id of project where deployed in Walrus."
}

output "walrus_environment_name" {
  value       = try(local.context["environment"]["name"], null)
  description = "The name of environment where deployed in Walrus."
}

output "walrus_environment_id" {
  value       = try(local.context["environment"]["id"], null)
  description = "The id of environment where deployed in Walrus."
}

output "walrus_service_name" {
  value       = try(local.context["service"]["name"], null)
  description = "The name of service where deployed in Walrus."
}

output "walrus_service_id" {
  value       = try(local.context["service"]["id"], null)
  description = "The id of service where deployed in Walrus."
}

#
# Submodule output
#

output "submodule" {
  value       = module.submodule.message
  description = "The message from submodule."
}
