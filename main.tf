
terraform {
  required_version = "~> 0.12.6"
}

/******************************************
  Project random id suffix configuration
 *****************************************/
resource "random_id" "random_project_id_suffix" {
  byte_length = 2
}

# ----------------------------------------------------------------------------------------------------------------------
# Locals
# ----------------------------------------------------------------------------------------------------------------------

locals {
  group_id          = var.manage_group ? var.admin_group_email : ""
  base_project_id   = var.project_id == "" ? var.name : var.project_id //
  project_org_id    = var.folder_id != "" ? "" : var.org_id
  project_folder_id = var.folder_id != "" ? var.folder_id : ""
  admin_group_id    = var.admin_group_email != "" ? var.admin_group_email : ""
  user_group_id     = var.user_group_email != "" ? var.user_group_email : ""
  temp_project_id = var.random_project_id ? format(
    "%s-%s",
    local.base_project_id,
    random_id.random_project_id_suffix.hex,
  ) : local.base_project_id
  s_account_fmt = format(
    "serviceAccount:%s",
    google_service_account.default_service_account.email,
  )
  api_s_account = format(
    "%s@cloudservices.gserviceaccount.com",
    google_project.main.number,
  )
  activate_apis_list     = var.activate_apis != "" ? split(",", var.activate_apis) : concat(var.activate_apis, ["iamcredentials.googleapis.com"])
  activate_apis          = var.impersonate_service_account != "" ? concat(var.activate_apis, ["iamcredentials.googleapis.com"]) : local.activate_apis_list
  api_s_account_fmt      = format("serviceAccount:%s", local.api_s_account)
  gke_shared_vpc_enabled = var.shared_vpc != "" && contains(local.activate_apis, "container.googleapis.com") ? "true" : "false"
   gke_s_account = format(
     "service-%s@container-engine-robot.iam.gserviceaccount.com",
     google_project.main.number,
   )
   gke_s_account_fmt = local.gke_shared_vpc_enabled ? format("serviceAccount:%s", local.gke_s_account) : ""

   shared_vpc_users = compact(
     [
       local.group_id,
       local.s_account_fmt,
       local.api_s_account_fmt,
       local.gke_s_account_fmt,
     ],
   )

  # Workaround for https://github.com/hashicorp/terraform/issues/10857
   shared_vpc_users_length = local.gke_shared_vpc_enabled ? 4 : 3
}

# ----------------------------------------------------------------------------------------------------------------------
# PROJECT
# ----------------------------------------------------------------------------------------------------------------------

resource "null_resource" "preconditions" {
  triggers = {
    credentials_path = var.credentials_path == "" ? 1 : 0
    billing_account  = var.billing_account
    org_id           = var.org_id
    folder_id        = var.folder_id
    shared_vpc       = var.shared_vpc
  }
}

/*******************************************
  Project creation
 *******************************************/
resource "google_project" "main" {
  name                = var.name
  project_id          = local.temp_project_id
  org_id              = local.project_org_id
  folder_id           = local.project_folder_id
  billing_account     = var.billing_account
  auto_create_network = var.auto_create_network
  labels = {
    env     = var.environment
    project = var.name
  }
  depends_on = [null_resource.preconditions]
}


/******************************************
  Project lien
 *****************************************/
resource "google_resource_manager_lien" "lien" {
  count        = var.lien ? 1 : 0
  parent       = "projects/${google_project.main.number}"
  restrictions = ["resourcemanager.projects.delete"]
  origin       = "project-factory"
  reason       = "Project Factory lien"
}

/******************************************
  Default Service Account configuration
 *****************************************/
resource "google_service_account" "default_service_account" {
  account_id   = "project-service-account"
  display_name = "${var.name} Project Service Account"
  project      = google_project.main.project_id
}

/******************************************
  APIs configuration
 *****************************************/
resource "google_project_service" "project_services" {
  count = var.apis_authority ? 0 : length(local.activate_apis)

  project = google_project.main.project_id
  service = element(local.activate_apis, count.index)

  disable_on_destroy         = var.disable_services_on_destroy
  disable_dependent_services = var.disable_dependent_services

  depends_on = [google_project.main]
}

# resource "google_project_services" "project_services_authority" {
#   count = var.apis_authority ? 1 : 0

#   project  = google_project.main.project_id
#   services = local.activate_apis

#   depends_on = [google_project.main]
# }

/******************************************
  Default compute service account retrieval
 *****************************************/
data "null_data_source" "default_service_account" {
  inputs = {
    email = "${google_project.main.number}-compute@developer.gserviceaccount.com"
  }
}

/******************************************
  Gsuite Admin Group Role Configuration
 *****************************************/
resource "google_project_iam_member" "gsuite_admin_group_role" {
  count = var.manage_group ? 1 : 0

  member  = local.admin_group_id
  project = google_project.main.project_id
  role    = var.admin_group_role
}

/******************************************
  Gsuite User Group Role Configuration
 *****************************************/
resource "google_project_iam_member" "gsuite_user_group_role" {
  count = var.manage_group ? 1 : 0

  member  = local.user_group_id
  project = google_project.main.project_id
  role    = var.user_group_role
}

/******************************************************************************************************************
  compute.networkUser role granted to G Suite group, APIs Service account, Project Service Account, and GKE Service
  Account on shared VPC
 *****************************************************************************************************************/
resource "google_project_iam_member" "controlling_group_vpc_membership" {
  count = var.shared_vpc != "" && length(compact(var.shared_vpc_subnets)) == 0 ? local.shared_vpc_users_length : 0

  project = var.shared_vpc_project
  role    = "roles/compute.networkUser"
  member  = element(local.shared_vpc_users, count.index)

  depends_on = [
    google_project_service.project_services
  ]
}

/*************************************************************************************
  compute.networkUser role granted to Project Service Account on vpc subnets
 *************************************************************************************/
resource "google_compute_subnetwork_iam_member" "service_account_role_to_vpc_subnets" {
  provider = google-beta

  count = var.shared_vpc != "" && length(compact(var.shared_vpc_subnets)) > 0 ? length(var.shared_vpc_subnets) : 0

  subnetwork = element(
    split("/", var.shared_vpc_subnets[count.index]),
    index(
      split("/", var.shared_vpc_subnets[count.index]),
      "subnetworks",
    ) + 1,
  )
  role = "roles/compute.networkUser"
  region = element(
    split("/", var.shared_vpc_subnets[count.index]),
    index(split("/", var.shared_vpc_subnets[count.index]), "regions") + 1,
  )
  project = var.shared_vpc_project
  member  = local.s_account_fmt
}

/*************************************************************************************
  compute.networkUser role granted to GSuite group on vpc subnets
 *************************************************************************************/
resource "google_compute_subnetwork_iam_member" "group_role_to_vpc_subnets" {
  provider = google-beta

  count = var.shared_vpc != "" && length(compact(var.shared_vpc_subnets)) > 0 && var.manage_group ? length(var.shared_vpc_subnets) : 0

  subnetwork = element(
    split("/", var.shared_vpc_subnets[count.index]),
    index(
      split("/", var.shared_vpc_subnets[count.index]),
      "subnetworks",
    ) + 1,
  )
  role = "roles/compute.networkUser"
  region = element(
    split("/", var.shared_vpc_subnets[count.index]),
    index(split("/", var.shared_vpc_subnets[count.index]), "regions") + 1,
  )
  member  = local.group_id
  project = var.shared_vpc_project
}


/*************************************************************************************
  compute.networkUser role granted to APIs Service Account on vpc subnets
 *************************************************************************************/
resource "google_compute_subnetwork_iam_member" "apis_service_account_role_to_vpc_subnets" {
  provider = google-beta

  count = var.shared_vpc != "" && length(compact(var.shared_vpc_subnets)) > 0 ? length(var.shared_vpc_subnets) : 0

  subnetwork = element(
    split("/", var.shared_vpc_subnets[count.index]),
    index(
      split("/", var.shared_vpc_subnets[count.index]),
      "subnetworks",
    ) + 1,
  )
  role = "roles/compute.networkUser"
  region = element(
    split("/", var.shared_vpc_subnets[count.index]),
    index(split("/", var.shared_vpc_subnets[count.index]), "regions") + 1,
  )
  project = var.shared_vpc_project
  member  = local.api_s_account_fmt

  depends_on = [
    google_project_service.project_services
  ]
}

/******************************************
  compute.networkUser role granted to GKE service account for GKE on shared VPC subnets
 *****************************************/
resource "google_compute_subnetwork_iam_member" "gke_shared_vpc_subnets" {
  provider = google-beta

  count = local.gke_shared_vpc_enabled && length(compact(var.shared_vpc_subnets)) != 0 ? length(var.shared_vpc_subnets) : 0

  subnetwork = element(
    split("/", var.shared_vpc_subnets[count.index]),
    index(
      split("/", var.shared_vpc_subnets[count.index]),
      "subnetworks",
    ) + 1,
  )
  role = "roles/compute.networkUser"
  region = element(
    split("/", var.shared_vpc_subnets[count.index]),
    index(split("/", var.shared_vpc_subnets[count.index]), "regions") + 1,
  )
  project = var.shared_vpc_project
  member  = local.gke_s_account_fmt

  depends_on = [
    google_project_service.project_services
  ]
}

/******************************************
  container.hostServiceAgentUser role granted to GKE service account for GKE on shared VPC
 *****************************************/
resource "google_project_iam_member" "gke_host_agent" {
  count = local.gke_shared_vpc_enabled ? 1 : 0

  project = var.shared_vpc_project
  role    = "roles/container.hostServiceAgentUser"
  member  = local.gke_s_account_fmt

  depends_on = [
    google_project_service.project_services
  ]
}

/*****************************************
Enable OSLogin in this created project
 *****************************************/
resource "google_compute_project_metadata_item" "enable_os_login" {
  key   = "enable-oslogin"
  value = "TRUE"
  project = google_project.main.project_id

  depends_on = [google_project.main]
}
