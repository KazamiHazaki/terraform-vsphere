provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}


data "vsphere_datacenter" "datacenter" {
  name = "type-your-datacenter-name"
}
 

data "vsphere_datastore" "datastore" {
  name          = "type-your-datastore-name"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}


data "vsphere_compute_cluster" "cluster" {
  name          = "type-your-cluster-name"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

 

data "vsphere_network" "network" {
  name          = "type-your-network-name"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

 

data "vsphere_virtual_machine" "template" {
  name = "type-your-vm-template-name"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}


data "vsphere_host" "hosts" {
  count = length(var.hostnames)   
  name  = var.hostnames[count.index]   
  datacenter_id = data.vsphere_datacenter.datacenter.id
}


resource "vsphere_virtual_machine" "vm" {
  count            = 20
  name             = format("my-vm%02d", count.index + 1 > 9 ? count.index + 1 : "0" + (count.index + 1))
  firmware         = var.vm_resource["firmware"]
  num_cpus         = 2
  num_cores_per_socket = 2
  memory           = data.vsphere_virtual_machine.template.memory
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  
  wait_for_guest_ip_timeout= 0
  wait_for_guest_net_timeout= 0
  wait_for_guest_net_routable = true

  # VM will installed based on host already defined in data Hosts
  host_system_id= data.vsphere_host.hosts[count.index].id

  # Configure network interface
  network_interface {
    network_id = data.vsphere_network.network.id
  }

  
  # Configure Disk 1
  disk {
    label = "vm-disk-${count.index + 1}-1"
    size = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
    unit_number= 0
  }

  # Configure Disk 2
  disk {
    label = "vm-disk-${count.index + 1}-2"
    size = data.vsphere_virtual_machine.template.disks.1.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.1.thin_provisioned
    unit_number= 1
  }

  # Define template and customisation params
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "kazamihazaki-vm${count.index + 1}"
        domain    = "localhost"
      }

      network_interface {
        ipv4_address    = "${var.base_ip}${25 + count.index}"
        ipv4_netmask    = 25
      }

      ipv4_gateway = "192.168.1.254"
    }
  }
}