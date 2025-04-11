
variable "vsphere_user" {
  description = "user for access vSphere vCenter appliance with"
  type        = string
  sensitive   = true
}

variable "VSPHERE_PASSWORD" {
  description = "Password associated with account for accessing vSphere vCenter appliance with"
  type        = string
  sensitive   = true
}

/*
variable "vsphere_server1" {
  description = "The vSphere password"
  type        = string
}

variable "vsphere_server2" {
  description = "The vSphere password"
  type        = string
}


# variables.tf

variable "vsphere_tag" {
  description = "existing tag"
  type        = string
}

variable "vsphere_tag_category" {
  description = "existing vsphere_tag_category"
  type        = string
}
*/
variable "virtual_machines_linux" {
  type = map(object({
    vsphere_cluster     = string
    vsphere_datastore   = string
    vsphere_network     = string
    vsphere_network1    = string
    vsphere_dc          = string
    vm_template         = string
    name          = string
    compute_node  = bool
    ipv4_address  = string
    ipv4_netmask  = string
    ipv4_address_bkp  = string
    ipv4_netmask_bkp  = string
    ipv4_gateway  = string
    dns_server    = string
    vm_domain    = string
    memory           = number
    logical_cpu   = number
    guest_id   = string
    firmware = string
    os_disk_size  = number
    px_disk_size  = number
    vm_linked_clone  = bool
    serverpassword    = string
    OS    = string
    vsphere    = string
    vsphere_tag_category = string
    vsphere_tag = string
  }))
}