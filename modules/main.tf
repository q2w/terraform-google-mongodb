/**
 * Copyright 2026 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {

#project_id       = var.gcp_project_id # Mention your GCP Project ID
suffix           = var.suffix         # Change the suffix.
mongo_location   = var.atlas_region   # Change the MongoDB location based on your requirement
#gcp_region       = var.gcp_region # Change the GCP Region based on your requirement
#gcp_zone         = var.gcp_zone # Change the GCP Zone based on your requirement
#user_invite_list = var.user_invite_list # List of users to receive the mongodbatlas project invitation e.g. ["abc@google.com", "cde@google.com"]
user_invite_list = tolist(split(", ", var.user_invite_list))
### No need to change any other values ###
}

data "google_secret_manager_secret_version" "db_secret_password" {
  count = var.database_password_secret != "" && var.database_password_secret != null ? 1 : 0
  project = var.project_id
  secret  = var.database_password_secret 
  version = "latest"           
}

resource "mongodbatlas_project" "project" {
name   = var.atlas_project_name  
org_id = var.atlas_org_id 
}


resource "mongodbatlas_cluster" "cluster" {
project_id                  = mongodbatlas_project.project.id
name                        = var.cluster_name 
provider_name               = "GCP"
provider_instance_size_name = var.instance_size 
provider_region_name        = local.mongo_location
mongo_db_major_version      = var.mongo_db_major_version
}

resource "mongodbatlas_project_invitation" "project_invite" {
 count      = length(local.user_invite_list)
 project_id = mongodbatlas_project.project.id
 username   = local.user_invite_list[count.index]
 roles      = var.user_project_roles
}

resource "mongodbatlas_database_user" "database_user" {
  username           = var.database_user_name
  password           = one(data.google_secret_manager_secret_version.db_secret_password[*].secret_data)
  project_id         = mongodbatlas_project.project.id
  auth_database_name = "admin"

  roles {
    role_name     = "readAnyDatabase"
    database_name = "admin"
  }
}

# resource "mongodbatlas_project_ip_access_list" "network_whitelist" {
#   for_each = var.network_whitelist.enable_whitelist ? toset(var.network_whitelist.ip_address) : []
#   project_id = mongodbatlas_project.project.id
#   ip_address = each.value
#   cidr_block = var.network_whitelist.network_cidr
# }


resource "mongodbatlas_project_ip_access_list" "network_whitelist" {
  for_each = var.network_whitelist.enable_whitelist ? toset(
    # Use compact() to remove nulls, and flatten to ensure we are working with a clean list
    compact(concat(
      # If ip_address is null, we provide an empty list []
      var.network_whitelist.ip_address != null ? var.network_whitelist.ip_address : [],
      # If network_cidr is null, we provide an empty list []
      var.network_whitelist.network_cidr != null ? [var.network_whitelist.network_cidr] : []
    ))
  ) : toset([])

  project_id = mongodbatlas_project.project.id

  # Check if the current value is a CIDR block or a single IP
  ip_address = can(regex("/", each.value)) ? null : each.value
  cidr_block = can(regex("/", each.value)) ? each.value : null
}