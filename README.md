# Módulo Terraform - GCP - PROJECT

<!-- TODO: revisar concordância e sentido da frase abaixo. -->
Módulo do Terraform para provisionamento de recursos do GCP Project (GCP).

## Uso

```hcl
module "project" {
  source = "git::ssh://git@example.com/terraform-modules/google/project.git?ref=master"

  name                        = "tf-simple-project"
  admin_group_email           = "group:admin@mandic.net.br"
  admin_group_role            = "roles/owner"
  user_group_email            = "group:users@mandic.net.br"
  user_group_role             = "roles/viewer"
  org_id                      = ""
  project_id                  = "${var.name}"
  shared_vpc                  = ""
  billing_account             = "AAAAAA-BBBBBB-CCCCCC"
  folder_id                   = ""
  activate_apis               = "${var.activate_apis}"
  apis_authority              = "${var.apis_authority}"
  manage_group                = "${var.admin_group_email} != "" ? true : false }"
  environment                 = "${var.environment}"
}
```

## Recursos provisionados

<!-- TODO: alterar lista de recursos provisionados pelo módulo. -->
- Criação de Projetos


## Customizações

<!-- TODO: ajustar exemplo de customização conforme necessário. -->

## Exemplos

<!-- TODO: alterar título e link abaixo conforme diretório de exemplo criado. -->
- [Exemplo simples](examples/simple-example/)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| admin\_group\_email | Email do Grupo Admin do project | string | null | yes |
| admin\_group\_role | Papel do Grupo Admin | string | null | yes |
| user\_group\_email | Email do Grupo User do Project | string | null | yes |
| user\_group\_role | Papel do Grupo User | string | null | yes | 
| manage\_group | Gerenciamento de um grupo GSuite | string | false | yes | 
| lien | Garantia para evitar exclusão acidental | string | false | no | 
| project\_id | Cria um ID do projeto, deve ser fornecido o valor random\_project\_id | string | null | yes | 
| random\_project\_id | Utilizado em conjunto com o project\_id | string | false | no | 
| folder\_id | ID de uma pasta pai | string | null | yes | 
| org\_id | ID de uma organização | string | n/a | yes | 
| name | Nome do Projeto | string | n/a | yes | 
| shared\_vpc | ID do host-project que contem uma Shared VPC | string | n/a | yes | 
| billing\_account | ID da Billing Account associada ao projeto | string | n/a | yes | 
| sa\_role | Papel que a SA padrão irá utilizar | string | n/a | no |
| apis\_authority | Gerenciamento autoritativo de Svc de Projeto | string | false | no | 
| activate\_apis | Lista de apis ativados no projeto | list(string) | compute.googleapis.com | yes | | shared\_vpc\_subnets | Lista de Subnets criadas em uma Shared VPC | list(string) | n/a | no | 
| labels | Mapa de Labels para o Projeto | map(string) | n/a | yes | 
| auto\_create\_network | Criação da rede default  | string | false | no |
| environment | Labels de ambientes | string | n/a | yes |  
  

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Licença

Copyright © 2019 Mandic Cloud Solutions. Todos os direitos reservados.
