/**
 * Copyright 2021 Google LLC
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


variable "atlas_public_key_secret" {
 type    = string
 default = ""
}

variable "atlas_private_key_secret" {
 type    = string
 default = ""
}


variable "atlas_org_id" {
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
 default = "xyz@abc.com" #e.g. "abs@xyz.com"
}

variable "atlas_project_name" {
 type    = string
 default = "prj2"
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

variable "project_id" {
 type    = string
 default = ""
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
        network_cidr = "0.0.0.0/0"
    }
}