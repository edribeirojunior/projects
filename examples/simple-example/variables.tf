variable "name" {
  default = "tf-shared-vpc-project"
}

variable "activate_apis" {
  default = "container.googleapis.com,iam.googleapis.com,compute.googleapis.com"
}

 variable "apis_authority" {
   default = false
 }

variable "credentials_path" {
  default = ""
}

variable "org_id" {
  default = ""
}

variable "folder_id" {
  default = ""
}

variable "admin_group_email" {
  default = ""
}

variable "user_group_email" {
  default = ""
}

variable "disable_services_on_destroy" {
  default = "true"
  type    = string
}

variable "disable_dependent_services" {
  default = "true"
  type    = string
}

variable "environment" {
}


