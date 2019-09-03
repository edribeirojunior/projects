variable "credentials_path" {
  description = "Path to a service account credentials file with rights to run the Project Factory. If this file is absent Terraform will fall back to Application Default Credentials."
  default     = ""
}

variable "admin_group_email" {
  description = "O endereço de email de um grupo de usuários para controlar o projeto ao ser atribuído admin_group_role."
  default     = ""
}

variable "admin_group_role" {
  description = "O papel para dar o grupo de controle (group_name) sobre o projeto."
  default     = ""
}

variable "user_group_email" {
  description = "O endereço de email de um grupo de usuários para controlar o projeto ao ser atribuído user_group_role."
  default     = ""
}

variable "user_group_role" {
  description = "O papel para dar o grupo de controle (group_name) sobre o projeto."
  default     = ""
}

variable "manage_group" {
  description = "Alternar para indicar se um grupo do G Suite deve ser gerenciado."
  default     = "false"
}

variable "lien" {
  description = "Adicione uma garantia no projeto para evitar exclusão acidental"
  default     = "false"
}

variable "impersonate_service_account" {
  description = "An optional service account to impersonate. If this service account is not specified, Terraform will fall back to credential file or Application Default Credentials."
  default     = ""
}

variable "project_id" {
  description = "Se fornecido, o projeto usa o ID do projeto fornecido. Exclusivo mutuamente com random_project_id sendo verdadeiro."
  default     = ""
}

variable "random_project_id" {
  description = "Permite a geração de id aleatório do projeto. Exclusivo mutuamente com project_id sendo não vazio."
  default     = "false"
}

variable "folder_id" {
  description = "ID de uma pasta que que irá segregar este projeto"
  default     = ""
}

variable "org_id" {
  description = "ID da Organização"
}

variable "name" {
  description = "Nome do Projeto"
}

variable "shared_vpc" {
  description = "Habilitar Shared VPC"
  default     = ""
}

variable "shared_vpc_project" {
  description = "ID do host-project que contém uma Shared VPC"
  default     = ""
}

variable "billing_account" {
  description = "ID da billing account para associar este projeto"
}

variable "sa_role" {
  description = "Uma função para fornecer a conta de serviço padrão para o projeto (o padrão é nenhum)"
  default     = ""
}

variable "apis_authority" {
  description = "Alterna o gerenciamento autoritativo de serviços de projeto."
  default     = false
}

variable "activate_apis" {
  description = "A lista de apis para ativar dentro do projeto"
  type        = string
}

variable "shared_vpc_subnets" {
  description = "Lista de sub-redes IDs de sub-rede totalmente qualificadas (por exemplo, projetos / $ project_id / regions / $ region / subnetworks / $ subnet_id)"
  type        = list(string)
  default     = [""]
}

variable "labels" {
  description = "Mapa de labels para projeto"
  type        = map(string)
  default     = {}
}

variable "auto_create_network" {
  description = "Criar a rede default"
  default     = "false"
}

variable "disable_services_on_destroy" {
  description = "Se os serviços do projeto serão desativados quando os recursos forem destruídos"
  default     = "true"
  type        = string
}

variable "default_service_account" {
  description = "Configuração da conta de serviço padrão do projeto: pode ser uma das opções `delete`,` depriviledge` ou `keep`."
  default     = "depriviledge"
  type        = string
}

variable "disable_dependent_services" {
  description = "Whether services that are enabled and which depend on this service should also be disabled when this service is destroyed."
  default     = "true"
  type        = string
}

variable "environment" {
  description = "Descrição do Environment"
}
