# data.tf

data "vsphere_datacenter" "dc" {
//for_each = { for k, v in var.virtual_machines_linux : k => v if lower(v.OS) == "linux" && v.vsphere == "vsphere_8_20"}
  for_each = var.virtual_machines_linux

  name = each.value.vsphere_dc
}

data "vsphere_compute_cluster" "cluster" {
  for_each = var.virtual_machines_linux

  name          = each.value.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.dc[each.key].id
}
/*
data "vsphere_host" "host" {
  for_each = var.virtual_machines_linux

  name          = each.value.vsphere_host
  datacenter_id = data.vsphere_datacenter.dc[each.key].id
}*/

data "vsphere_datastore" "datastore" {
  for_each = var.virtual_machines_linux
  

  name          = each.value.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc[each.key].id
}

data "vsphere_network" "network" {
  for_each = var.virtual_machines_linux

  name          = each.value.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc[each.key].id
}

data "vsphere_network" "network1" {
  for_each = var.virtual_machines_linux

  name          = each.value.vsphere_network1
  datacenter_id = data.vsphere_datacenter.dc[each.key].id
}

# Uncomment these data blocks if you need to access additional data
# data "vsphere_resource_pool" "pool" {
#   for_each = local.virtual_machine_data

#   name          = each.value.vsphere_resource_pool
#   datacenter_id = data.vsphere_datacenter.dc[each.key].id
# }

data "vsphere_virtual_machine" "template" {
  for_each = var.virtual_machines_linux

  name          = each.value.vm_template
  datacenter_id = data.vsphere_datacenter.dc[each.key].id
}

data "vsphere_tag" "existing_tag" {
  for_each = var.virtual_machines_linux
 // name = "wp_vmvmaa_tag"
 name= each.value.vsphere_tag
 category_id = "${data.vsphere_tag_category.category[each.key].id}"
}

data "vsphere_tag_category" "category" {
  for_each = var.virtual_machines_linux
  name= each.value.vsphere_tag_category
//  cardinality = "SINGLE"
 // description = "Managed by Terraform"

 // associable_types = [
 //   "VirtualMachine"
 // ]
}

# data "vsphere_datastore" "example_datastore"{
#   for_each = local.virtual_machine_data

#   name          = "xxxxxxxxxxx"   # Provide the datastore name here if it's fixed for all VMs
#   datacenter_id = data.vsphere_datacenter.dc[each.key].id
# }

# data "vsphere_datastore" "datastore" {
#   for_each = local.virtual_machine_data

#   name          = each.value.vsphere_datastore
#   datacenter_id = data.vsphere_datacenter.dc[each.key].id
# }