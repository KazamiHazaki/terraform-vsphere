
---

# Terraform vSphere VM Deployment

## Overview

This guide demonstrates how to use Terraform to deploy virtual machines (VMs) in a vSphere environment using a template VM. Terraform automates the provisioning process and allows you to create multiple VMs based on the template.

### Software Versions

- Terraform: v1.5.6
- Terraform vSphere Provider: v2.4.2
- vCenter: 8
- Template VM: RHEL 9

## Prerequisites

Before getting started, make sure you have the following in place:

1. **Terraform Installed**: Ensure you have Terraform installed on your system.

2. **vSphere Configuration**: Set up your vSphere environment and gather the necessary information, including:
   - vSphere username and password
   - vSphere server address
   - Datacenter name
   - Datastore name
   - Cluster name
   - Network name
   - Template VM name

3. **Template VM**: Ensure that you have a template VM with the required configurations. Note that Perl should be installed in the template VM as it is used by VMware Tools.

## Usage

1. **Provider Configuration**: Configure the vSphere provider in your Terraform configuration. Replace placeholders with your vSphere credentials.

   ```hcl
   provider "vsphere" {
     user                 = "your-username"
     password             = "your-password"
     vsphere_server       = "your-vsphere-server"
     allow_unverified_ssl = true
   }
   ```

2. **Data Sources**: Define data sources for your vSphere environment, including datacenter, datastore, cluster, network, and the template VM. Replace placeholders with your environment-specific information.

   ```hcl
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
   ```

3. **Resource Configuration**: Configure the VM resources, including name, CPU, memory, disks, and networking. Replace placeholders as needed. Ensure you specify the desired customization options.

   ```hcl
   resource "vsphere_virtual_machine" "vm" {
     count            = 20
     name             = format("my-vm%02d", count.index + 1)
     # ... (Specify CPU, memory, disks, and other configurations)

     # Define template and customization params
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
   ```

4. **Terraform Commands**: Run the following Terraform commands to apply your configuration and deploy the VMs:

   ```sh
   terraform init
   terraform plan
   terraform apply
   ```

## Notes

- Ensure that Perl is installed in your template VM. Perl is required by VMware Tools, and failure to have Perl installed may result in issues during the cloning process.

---

This README provides a high-level overview of how to use Terraform with vSphere to deploy VMs based on a template. Make sure to replace the placeholders with your specific configuration details, and follow the Terraform commands for provisioning your VMs.