locals {
  credentials_file_path = var.credentials_path
}

provider "google" {
  credentials = file(local.credentials_file_path)
}

provider "google-beta" {
  credentials = file(local.credentials_file_path)

}


# ----------------------------------------------------------------------------------------------------------------------
# PROJECT
# ----------------------------------------------------------------------------------------------------------------------

module "project" {
  source = "../../"

  ## Requeridos
  name                        = "${var.name}"
  admin_group_email           = "group:${var.admin_group_email}"
  admin_group_role            = "roles/owner"
  user_group_email            = "group:${var.user_group_email}"
  user_group_role             = "roles/viewer"
  org_id                      = "${var.org_id}"
  project_id                  = "${var.name}"
  shared_vpc                  = ""
  shared_vpc_project          = ""
  billing_account             = "01BD07-2E6EE4-EDF01B"
  folder_id                   = "${var.folder_id}"
  activate_apis               = "${var.activate_apis}"
  manage_group                = var.admin_group_email != "" ? true : false
  disable_services_on_destroy = var.disable_services_on_destroy
  disable_dependent_services  = var.disable_dependent_services
  environment = var.environment

  ## Não Requeridos
  // random_project_id           = var.random_project_id // Se não existir não criará um nome randomico 
  // lien                        = "false"
  // credentials_path            = local.credentials_file_path
  // impersonate_service_account = var.impersonate_service_account
  // shared_vpc_subnets          = var.shared_vpc_subnets
  // sa_role                     = var.sa_role
  // auto_create_network         = "false"
  // default_service_account     = var.default_service_account
  // apis_authority    = "${var.apis_authority}"
}
