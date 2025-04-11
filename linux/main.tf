### ADDON 1 - To address the requirement to set a precondition to validate that there are sufficient capacity on the datastore

/* locals {
  join_user_password        = join(":", [var.vsphere_user, var.VSPHERE_PASSWORD])
  encode_join_user_password = base64encode(local.join_user_password)
}

data "http" "vsphere_cis_create_session" {
  url = "https://${var.vsphere_server}/api/session"
  insecure = true

  method = "POST"
  request_headers = {
    Authorization = "Basic ${local.encode_join_user_password}"
  }
}


data "http" "vcenter_get_datastore" {
  url = "https://${var.vsphere_server}/api/vcenter/datastore/${data.vsphere_datastore.datastore.id}"
  insecure = true

  method = "GET"
  request_headers = {
    "vmware-api-session-id" = "${data.http.vsphere_cis_create_session.response_headers.Vmware-Api-Session-Id}"
  }
}
*/
### END OF ADDON 1

/*
resource "vsphere_tag" "tag" {
  name        = "app-server"
  category_id = "${vsphere_tag_category.category.id}"
  description = "Managed by Terraform"
}*/

resource "vsphere_virtual_machine" "linux_vm1" {
  //resource_pool_id = data.vsphere_resource_pool.pool.id
  for_each = { for k, v in var.virtual_machines_linux : k => v if lower(v.OS) == "linux" && v.vsphere == "vsphere_8_20"}
  #for_each = var.virtual_machines[terraform.workspace]
  #for_each = lower(var.linux_OS) == "linux" ? var.virtual_machines_linux[terraform.workspace] : {}
  //  tags = ["${vsphere_tag.existing_tag.id}"]
    tags = [
    data.vsphere_tag.existing_tag[each.key].id
  ]
    provider   = vsphere.vsphere_8_20
    name       = each.value.name
    memory     = each.value.memory
    num_cpus   = each.value.logical_cpu
    cpu_hot_add_enabled    = true
    memory_hot_add_enabled = true
    extra_config_reboot_required = false
    guest_id   = each.value.guest_id
    firmware = each.value.firmware
    scsi_controller_count = 2
    //scsi_type = data.vsphere_virtual_machine.source_template.scsi_type

  resource_pool_id = data.vsphere_compute_cluster.cluster[each.key].resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore[each.key].id

  network_interface {
      network_id   = data.vsphere_network.network[each.key].id
      //adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
    }

   network_interface {
      network_id   = data.vsphere_network.network1[each.key].id
    }

   

    disk {
      unit_number      = 0
      label            = "OS"
      size             = each.value.os_disk_size
     eagerly_scrub    = data.vsphere_virtual_machine.template[each.key].disks.0.eagerly_scrub
     thin_provisioned = data.vsphere_virtual_machine.template[each.key].disks.0.thin_provisioned
    }   
    
    
    dynamic "disk" {
      for_each = each.value.compute_node ? [1] : []
        content {
        unit_number      = 3
        label            = "PX"
        size             = each.value.px_disk_size
        eagerly_scrub    = data.vsphere_virtual_machine.template[each.key].disks.0.eagerly_scrub
        thin_provisioned = data.vsphere_virtual_machine.template[each.key].disks.0.thin_provisioned
      }
    }

     dynamic "disk" {
      for_each = each.value.compute_node ? [1] : []
        content {
        unit_number      = 1
        label            = "poracle"
        size             = 20
        eagerly_scrub    = data.vsphere_virtual_machine.template[each.key].disks.0.eagerly_scrub
        thin_provisioned = data.vsphere_virtual_machine.template[each.key].disks.0.thin_provisioned
      }
    }

     dynamic "disk" {
      for_each = each.value.compute_node ? [1] : []
        content {
        unit_number      = 15
        label            = "poradata1"
        size             = 20
        eagerly_scrub    = data.vsphere_virtual_machine.template[each.key].disks.0.eagerly_scrub
        thin_provisioned = data.vsphere_virtual_machine.template[each.key].disks.0.thin_provisioned
      }
    }

    extra_config = {
      "disk.EnableUUID" = "TRUE"
    } 

    clone {
      template_uuid = data.vsphere_virtual_machine.template[each.key].id
      linked_clone  = each.value.vm_linked_clone

      customize {
        timeout = "20"

        linux_options {
          host_name = each.value.name
          domain    = each.value.vm_domain
        }

        network_interface {
          ipv4_address = each.value.ipv4_address 
          ipv4_netmask = each.value.ipv4_netmask 
        }

        network_interface {
          ipv4_address = each.value.ipv4_address_bkp
          ipv4_netmask = each.value.ipv4_netmask_bkp
        } 


        ipv4_gateway    = each.value.ipv4_gateway 
        dns_server_list = [ each.value.dns_server ]
      }
    }

  
  connection {
    host     = each.value.ipv4_address
    type     = "ssh"
    timeout  = "60s"
    user     = "root"
    password = "${each.value.serverpassword}"
  }
/*
  provisioner "file" {
    source      = "./setup-scripts/filesystem.cfg"
    destination = "/tmp/mounts"
  }

  provisioner "file" {
    source      = "./setup-scripts/fs.sh"
    destination = "/tmp/fs.sh"
  }

  provisioner "file" {
    source      = "./setup-scripts/server.cfg"
    destination = "/etc/uob/server.cfg"
  }
*/
  # provisioner "file" {
  #   source      = "./setup-scripts/users.txt"
  #   destination = "/tmp/users_file"
  # }

  # provisioner "file" {
  #   source      = "./setup-scripts/folders.txt"
  #   destination = "/tmp/folders_file"
  # }
/*
  provisioner "remote-exec" {
    inline = [
      "sh /tmp/fs.sh",
      #"cd /root && yum localinstall chef-16.13.16*.rpm -y",
      #"cd /root/bootstrap_v16",
      #"echo yes |sh chef-client-install.sh",
      #"chef-client",
    ]
    connection {
      host     = each.value.ipv4_address
      type     = "ssh"
      timeout  = "60s"
      user     = "root"
      password = "${var.serverpassword}"
      script_path = "/opt/bash.sh"
    }
  }
 
  ### Precondition to check that datastore has capacity (1TB)
  lifecycle {
    precondition {
      condition     = jsondecode(data.http.vcenter_get_datastore.response_body).free_space > 1000000000000
      error_message = "Insufficient capacity on ${var.vsphere_datastore}"
    }
  } 

  provisioner "remote-exec" {
    #when = var.ECOM == "yes" ? "create" : "never"
    inline = [
      "route add -net 192.168.0.0/24 gw ${each.value.ipv4_gateway}"
    ]
    connection {
      type        = "ssh"
      host        = each.value.ipv4_address
      user        = "root"
      password    = var.serverpassword
      port        = "22"
      agent       = false
    }
  }

  # File Creation
  provisioner "file" {
    source      = var.ENV == "SIT" ? "./sit.cfg" : var.ENV == "UAT" ? "./uat.cfg" : "./prd.cfg"
    destination = "/etc/sysconfig/network-scripts/${lower(var.ENV)}.cfg"
  }*/
}


resource "vsphere_virtual_machine" "linux_vm2" {
   provider   = vsphere.dojo
  //resource_pool_id = data.vsphere_resource_pool.pool.id
  for_each = { for k, v in var.virtual_machines_linux : k => v if lower(v.OS) == "linux" && v.vsphere == "dojo"}

  
  #for_each = var.virtual_machines[terraform.workspace]
  #for_each = lower(var.linux_OS) == "linux" ? var.virtual_machines_linux[terraform.workspace] : {}
 //   tags = ["${vsphere_tag.tag.id}"]
   
    name       = each.value.name
    memory     = each.value.memory
    num_cpus   = each.value.logical_cpu
    cpu_hot_add_enabled    = true
    memory_hot_add_enabled = true
    extra_config_reboot_required = false
    guest_id   = each.value.guest_id
    firmware = each.value.firmware

  resource_pool_id = data.vsphere_compute_cluster.cluster[each.key].resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore[each.key].id

  network_interface {
      network_id   = data.vsphere_network.network[each.key].id
      //adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
    }

   network_interface {
      network_id   = data.vsphere_network.network1[each.key].id
    }



    disk {
      unit_number      = 1
      label            = "OS"
      size             = each.value.os_disk_size
    eagerly_scrub    = data.vsphere_virtual_machine.template[each.key].disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template[each.key].disks.0.thin_provisioned
    }   
    
    
    dynamic "disk" {
      for_each = each.value.compute_node ? [1] : []
        content {
        unit_number      = 0
        label            = "PX"
        size             = each.value.px_disk_size
        eagerly_scrub    = data.vsphere_virtual_machine.template[each.key].disks.0.eagerly_scrub
        thin_provisioned = data.vsphere_virtual_machine.template[each.key].disks.0.thin_provisioned
      }
    }

    extra_config = {
      "disk.EnableUUID" = "TRUE"
    } 

    clone {
      template_uuid = data.vsphere_virtual_machine.template[each.key].id
      linked_clone  = each.value.vm_linked_clone

      customize {
        timeout = "20"

        linux_options {
          host_name = each.value.name
          domain    = each.value.vm_domain
        }

        network_interface {
          ipv4_address = each.value.ipv4_address 
          ipv4_netmask = each.value.ipv4_netmask 
        }

        network_interface {
          ipv4_address = each.value.ipv4_address_bkp
          ipv4_netmask = each.value.ipv4_netmask_bkp
        } 


        ipv4_gateway    = each.value.ipv4_gateway 
        dns_server_list = [ each.value.dns_server ]
      }
    }

  
  connection {
    host     = each.value.ipv4_address
    type     = "ssh"
    timeout  = "60s"
    user     = "root"
    password = "${each.value.serverpassword}"
  }
/*
  provisioner "file" {
    source      = "./setup-scripts/filesystem.cfg"
    destination = "/tmp/mounts"
  }

  provisioner "file" {
    source      = "./setup-scripts/fs.sh"
    destination = "/tmp/fs.sh"
  }

  provisioner "file" {
    source      = "./setup-scripts/server.cfg"
    destination = "/etc/uob/server.cfg"
  }
*/
  # provisioner "file" {
  #   source      = "./setup-scripts/users.txt"
  #   destination = "/tmp/users_file"
  # }

  # provisioner "file" {
  #   source      = "./setup-scripts/folders.txt"
  #   destination = "/tmp/folders_file"
  # }
/*
  provisioner "remote-exec" {
    inline = [
      "sh /tmp/fs.sh",
      #"cd /root && yum localinstall chef-16.13.16*.rpm -y",
      #"cd /root/bootstrap_v16",
      #"echo yes |sh chef-client-install.sh",
      #"chef-client",
    ]
    connection {
      host     = each.value.ipv4_address
      type     = "ssh"
      timeout  = "60s"
      user     = "root"
      password = "${var.serverpassword}"
      script_path = "/opt/bash.sh"
    }
  }
 
  ### Precondition to check that datastore has capacity (1TB)
  lifecycle {
    precondition {
      condition     = jsondecode(data.http.vcenter_get_datastore.response_body).free_space > 1000000000000
      error_message = "Insufficient capacity on ${var.vsphere_datastore}"
    }
  } 

  provisioner "remote-exec" {
    #when = var.ECOM == "yes" ? "create" : "never"
    inline = [
      "route add -net 192.168.0.0/24 gw ${each.value.ipv4_gateway}"
    ]
    connection {
      type        = "ssh"
      host        = each.value.ipv4_address
      user        = "root"
      password    = var.serverpassword
      port        = "22"
      agent       = false
    }
  }

  # File Creation
  provisioner "file" {
    source      = var.ENV == "SIT" ? "./sit.cfg" : var.ENV == "UAT" ? "./uat.cfg" : "./prd.cfg"
    destination = "/etc/sysconfig/network-scripts/${lower(var.ENV)}.cfg"
  }*/
}
