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

variable "project_id" {
 type    = string
 default = ""
}

variable "region" {
 type    = string
 default = "northamerica-northeast1"
}

variable "zone" {
 type    = string
 default = "northamerica-northeast1-a"
}


variable "suffix" {
 type    = string
 default = "s1"
}

variable "atlas_region" {
 type    = string
 default = "NORTH_AMERICA_NORTHEAST_1"
}


variable "user_invite_list" {
 type    = string
 default = ""
}

variable "atlas_project_name" {
 type    = string
 default = "project1"
}

variable "atlas_org_id" {
 type    = string
 default = ""
}

variable "cluster_name" {
 type    = string
 default = "lz-cluster1"
}


variable "instance_size" {
 type    = string
 default = "M10"
}

variable "mongo_db_major_version" {
 type    = string
 default = "7.0"
}

variable "user_project_roles" {
 description = "A list of roles to assign to the user within the project."
 type        = list(string)
 default     = ["GROUP_OWNER"] # Example: Project Read Only
 # Common roles:
 # GROUP_OWNER
 # GROUP_AUTOMATION_ADMIN
 # GROUP_MONITORING_ADMIN
 # GROUP_USER_ADMIN
 # GROUP_DATA_ACCESS_ADMIN
 # GROUP_DATA_ACCESS_READ_WRITE
 # GROUP_DATA_ACCESS_READ_ONLY
 # GROUP_READ_ONLY
}

variable "database_user_name" {
  description = "MongoDB User name"
  type        = string
  default = "admin"
}

variable "database_password_secret" {
  description = "MongoDB User Password secret name"
  type        = string
  default = ""
}

variable "network_whitelist" {
    type = object({
        enable_whitelist = optional(bool, false)
        ip_address = optional(list(string))
        network_cidr = optional(string)
    })
    default = {
        enable_whitelist = true
        #ip_address = ["10.10.10.10"]
        network_cidr = "0.0.0.0/0"
    }
}

