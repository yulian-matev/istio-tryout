# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}


variable "instance_type" {
  default = "t2.medium"   # t2.medium    $0.0464 vCPU: 2 Memory: 4 GiB
                          # t3.large     $0.0832 vCPU: 2 Memory: 8 GiB
}
