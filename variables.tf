variable "vsphere_user" {
        default = "kazamihazaki@vsphere.local"
}
variable "vsphere_password" {
	description = "password login"
	sensitive = true
}
variable "vsphere_server" {
	default = "kazami-lab-vcenter.local"
}
variable "vm_resource" {
	default = {
  firmware = "efi"
  }
}	

variable "base_ip" {
  default = "192.168.1."
}

 
variable "hostnames" {
  type = list(string)
  default = [
    "192.168.1.2",
    "192.168.1.3",
    "192.168.1.4",
    "192.168.1.5",
    "192.168.1.6",
    "192.168.1.7",
    "192.168.1.8",
    "192.168.1.9",
    "192.168.1.10",
    "192.168.1.11",
    "192.168.1.12",
    "192.168.1.13",
    "192.168.1.14",
    "192.168.1.15",
    "192.168.1.16",
    "192.168.1.17",
    "192.168.1.18",
    "192.168.1.19",
    "192.168.1.20",
    "192.168.1.21",
  ]
}
