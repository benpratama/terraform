# konfigurasi yang dipake terraform
terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = "2.7.0"
    }
  }
}   

# konfigurasinya dipake buat vsphere
provider "vsphere" {
  user           = "administrator@vsphere.local"
  password       = "@ut0Lab95619"
  vsphere_server = "192.168.119.2"
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "datacenter" {
  name = "TestDatacenter"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore_20"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "TestCluster"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "resource_pool" {
  name = "TestResourcePool"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = "DSwitch-VM Network"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_folder" "parent" {
  path = "k8s-ansible-ben"
  type = "vm"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

#! ###### UBUNTU ###### 
data "vsphere_virtual_machine" "template" {
  name          = "ubuntu-test"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "control_plane" {
  name = "110-t-control-plane"
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  datastore_id = data.vsphere_datastore.datastore.id
  folder = vsphere_folder.parent.path

  num_cpus = 2
  memory = 4096

  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type

  wait_for_guest_net_timeout = 0

  disk {
    label = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]  
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = "t-control-plane2"
        domain    = "control-plane"
      }
      network_interface {
        ipv4_address = "192.168.119.110"
        ipv4_netmask = "24"
      }
      ipv4_gateway = "192.168.119.1"
      dns_server_list = ["8.8.8.8", "8.8.4.4"]
    }
  }
}

resource "vsphere_virtual_machine" "control_plane2" {
  name = "111-control-plane-M"
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  datastore_id = data.vsphere_datastore.datastore.id
  folder = vsphere_folder.parent.path

  num_cpus = 2
  memory = 4096
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type

  wait_for_guest_net_timeout = 0

  disk {
    label = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]  
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    timeout = 180
    customize {
      linux_options {
        host_name = "control-plane-M"
        domain    = "control-plane"
      }
      network_interface {
        ipv4_address = "192.168.119.111"
        ipv4_netmask = 24
      }
      ipv4_gateway = "192.168.119.1"
      dns_server_list = ["8.8.8.8", "8.8.4.4"]
    }
  }
}

#! ###### WINDOWS ###### 
# #  FOR CREATING VM FROM TEMPLATE (windows-worker-node)
data "vsphere_virtual_machine" "template2" {
#   name          = "winserver2019_1809_include_VMware Tools"
  name          = "winServer2019_1809_include_VMwareTool"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# # output "guest_id" {
# #   value = data.vsphere_virtual_machine.template2.id
# # }

resource "vsphere_virtual_machine" "win_worker_node" {
  name = "112-win-worker-node"
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  datastore_id = data.vsphere_datastore.datastore.id
  folder = vsphere_folder.parent.path

  num_cpus = 2
  memory = 4096 
  firmware = "efi"

  guest_id         = data.vsphere_virtual_machine.template2.guest_id
  scsi_type        = data.vsphere_virtual_machine.template2.scsi_type

  wait_for_guest_net_timeout = 0

  disk {
    label = "disk0"
    size             = data.vsphere_virtual_machine.template2.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template2.disks.0.thin_provisioned
  }

  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template2.network_interface_types[0]  
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template2.id
    customize {
        windows_options {
            computer_name="administrator"
            admin_password = "@ut0Lab95619"
        }
        network_interface {
            ipv4_address = "192.168.119.112"
            ipv4_netmask = 24
        }
        ipv4_gateway = "192.168.119.1"
        dns_server_list = ["8.8.8.8", "8.8.4.4"]
    }
  }
}



