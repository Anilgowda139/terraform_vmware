#terraform {
#  required_providers {
#    vsphere = {
#      source  = "local/hashicorp/vsphere"
#      version = "2.3.1"
#    }
#    http = {
#      source  = "local/hashicorp/http"
#
#version = "3.2.1"
#    }
#  }
#}


terraform {
  required_providers {
    vsphere = {
      source  = "registry.terraform.io/hashicorp/vsphere"
      version = "2.3.1"
    }
  }
}
