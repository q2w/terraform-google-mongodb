# terraform-google-mongodb

## Description
### Tagline
This is an auto-generated module.

### Detailed
This module was generated from [terraform-google-module-template](https://github.com/terraform-google-modules/terraform-google-module-template/), which by default generates a module that simply creates a GCS bucket. As the module develops, this README should be updated.

The resources/services/activations/deletions that this module will create/trigger are:

- Create a GCS bucket with the provided name

### PreDeploy
To deploy this blueprint you must have an active billing account and billing permissions.

## Architecture
![alt text for diagram](https://www.link-to-architecture-diagram.com)
1. Architecture description step no. 1
2. Architecture description step no. 2
3. Architecture description step no. N

## Documentation
- [Hosting a Static Website](https://cloud.google.com/storage/docs/hosting-static-website)

## Deployment Duration
Configuration: X mins
Deployment: Y mins

## Cost
[Blueprint cost details](https://cloud.google.com/products/calculator?id=02fb0c45-cc29-4567-8cc6-f72ac9024add)

## Usage

Basic usage of this module is as follows:

```hcl
module "mongo_db" {

 source = "./modules"
 atlas_project_name = var.atlas_project_name
 suffix = var.suffix
 atlas_org_id = var.atlas_org_id
 cluster_name = var.cluster_name
 instance_size = var.instance_size
 atlas_region = var.atlas_region
 mongo_db_major_version = var.mongo_db_major_version
 user_invite_list = var.user_invite_list
 network_whitelist = var.network_whitelist
 project_id = var.project_id
 database_password_secret = var.database_password_secret

}
```

Functional examples are included in the
[examples](./examples/) directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| atlas\_org\_id | n/a | `string` | `""` | yes |
| atlas\_private\_key\_secret | n/a | `string` | `""` | yes |
| atlas\_project\_name | n/a | `string` | `"prj2"` | no |
| atlas\_public\_key\_secret | n/a | `string` | `""` | yes |
| atlas\_region | n/a | `string` | `"NORTH_AMERICA_NORTHEAST_1"` | no |
| cluster\_name | n/a | `string` | `"lz-cluster1"` | no |
| database\_password\_secret | MongoDB User Password secret name | `string` | `""` | yes |
| project\_id | n/a | `string` | `""` | yes |
| region | n/a | `string` | `"northamerica-northeast1"` | no |
| zone | n/a | `string` | `"northamerica-northeast1-a"` | no |
| instance\_size | n/a | `string` | `"M10"` | no |
| mongo\_db\_major\_version | n/a | `string` | `"7.0"` | no |
| network\_whitelist | n/a | <pre>object({<br>        enable_whitelist = optional(bool, false)<br>        ip_address = optional(list(string))<br>        network_cidr = optional(string)<br>    })</pre> | <pre>{<br>  "enable_whitelist": true,<br>  "ip_address": []<br>}</pre> | no |
| suffix | n/a | `string` | `"s1"` | no |
| user\_invite\_list | n/a | `string` | `"xyz@abc.com"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_id | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v0.13
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.0

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

- Storage Admin: `roles/storage.admin`

The [Project Factory module][project-factory-module] and the
[IAM module][iam-module] may be used in combination to provision a
service account with the necessary roles applied.

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Google Cloud Storage JSON API: `storage-api.googleapis.com`

The [Project Factory module][project-factory-module] can be used to
provision a project with the necessary APIs enabled.

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform]: https://www.terraform.io/downloads.html

## Security Disclosures

Please see our [security disclosure process](./SECURITY.md).
