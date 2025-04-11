provider "vsphere" {
  #for_each = var.virtual_machines_linux[terraform.workspace]
    user           = var.vsphere_user
    password       = var.VSPHERE_PASSWORD
    vsphere_server = "192.168.8.20"
    allow_unverified_ssl = true
}

provider "vsphere" {
  #for_each = var.virtual_machines_linux[terraform.workspace]
    alias          = "vsphere_8_20"
    user           = var.vsphere_user
    password       = var.VSPHERE_PASSWORD
    vsphere_server = "192.168.8.20"
    #vsphere_server = var.vsphere_server1
    allow_unverified_ssl = true
}

provider "vsphere" {
  #for_each = var.virtual_machines_linux[terraform.workspace]
    alias          = "dojo"
    user           = var.vsphere_user
    password       = var.VSPHERE_PASSWORD
    vsphere_server = "192.168.9.70"
    #vsphere_server = var.vsphere_server2
    allow_unverified_ssl = true
}