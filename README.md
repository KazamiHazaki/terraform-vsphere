
---

# Terraform vSphere VM Deployment

## Overview

This guide demonstrates how to use Terraform to deploy virtual machines (VMs) in a vSphere environment using a template VM. Terraform automates the provisioning process and allows you to create multiple VMs based on the template.


### Environment Overview

This Terraform configuration is designed to deploy virtual machines (VMs) in a vSphere environment. Below are some key details about the environment in which these VMs will be deployed:

- **Cluster**: The vSphere environment consists of a single cluster with a total of 35 hosts. Each host has a unique IP address within the range of `192.168.1.2` to `192.168.1.36`.

- **Host IP Range**: The host IP addresses start from `192.168.1.2`, and each host is assigned a unique IP address incrementing sequentially.

- **VM Placement**: The VMs will be installed on these hosts based on the IP address of each host. For example, if a VM is being deployed, it will be placed on the host with the IP address that corresponds to the VM's position in the list of VMs.

   - VM 1 will be placed on the host with IP `192.168.1.2`.
   - VM 2 will be placed on the host with IP `192.168.1.3`.
   - VM 3 will be placed on the host with IP `192.168.1.4`.
   - And so on, up to VM 35, which will be placed on the host with IP `192.168.1.36`.

- **VM IP Addresses**: VM IP addresses will start from `192.168.1.37` and increment sequentially for each VM.

### Usage

After configuring your Terraform environment, including setting the required variables and exporting the vCenter password, you can proceed to use Terraform to deploy VMs based on the provided environment details.

---


### Software Versions

- Terraform: v1.5.6
- Terraform vSphere Provider: v2.4.2
- vCenter: 8
- Template VM: RHEL 9
Thank you for the clarification. If your VM IP addresses start from `192.168.1.37`, you can update the relevant section in your README accordingly:

---

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

### Automated vCenter Login

To bypass the vCenter login prompt, you can set your vCenter password as an environment variable. Follow these steps:

1. Open your command-line terminal.

2. Run the following command to export your vCenter password as an environment variable:

   ```sh
   export TF_VAR_vsphere_password="your-vcenter-password"
   ```

   Replace `"your-vcenter-password"` with your actual vCenter password.

   **Note**: Be cautious when using environment variables to store sensitive information. Ensure that you handle the password securely and do not expose it unintentionally.

### Usage

After setting the `TF_VAR_vsphere_password` environment variable, you can proceed to use Terraform to deploy VMs as described in the previous sections of this README.

---
