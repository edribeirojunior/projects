output "project_name" {
  value = google_project.main.name
}

output "project_id" {
  value = element(
    concat(
      google_project_service.project_services.*.project,
      [google_project.main.project_id],
    ),
    0,
  )
}

output "project_number" {
  value = google_project.main.number
}

output "service_account_id" {
  value       = google_service_account.default_service_account.account_id
  description = "The id of the default service account"
}

output "service_account_display_name" {
  value       = google_service_account.default_service_account.display_name
  description = "The display name of the default service account"
}

output "service_account_email" {
  value       = google_service_account.default_service_account.email
  description = "The email of the default service account"
}

output "service_account_name" {
  value       = google_service_account.default_service_account.name
  description = "The fully-qualified name of the default service account"
}

output "service_account_unique_id" {
  value       = google_service_account.default_service_account.unique_id
  description = "The unique id of the default service account"
}

output "api_s_account" {
  value       = local.api_s_account
  description = "API service account email"
}

output "api_s_account_fmt" {
  value       = local.api_s_account_fmt
  description = "API service account email formatted for terraform use"
}