data "vsphere_virtual_machine" "template" {
  name          = var.rhcos_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

module "master" {
  source    = "../../modules/rhcos-static"
  count     = length(var.master_ips)
  name      = "tcbcmast0{count.index + 1}"
  folder    = "Openshift"
  datastore = data.vsphere_datastore.vsanDatastore.id
  disk_size = 160
  memory    = 32768
  num_cpu   = 8
  ignition  = file(var.master_ignition_path)

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  template         = data.vsphere_virtual_machine.template.id
  thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned

  network      = data.vsphere_network.network.id
  adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]

  cluster_domain = var.cluster_domain
  machine_cidr   = var.machine_cidr
  dns_address    = var.public_dns
  gateway        = var.gateway
  ipv4_address   = var.master_ips[count.index]
  netmask        = var.netmask
}

module "worker1" {
  source    = "../../modules/rhcos-static"
  count     = length(var.worker1_ips)
  name      = "tcbwkn0${count.index + 1}"
  folder    = "Openshift"
  datastore = data.vsphere_datastore.vsanDatastore.id
  disk_size = 160
  memory    = 32768
  num_cpu   = 8
  ignition  = file(var.worker_ignition_path)

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  template         = data.vsphere_virtual_machine.template.id
  thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned

  network      = data.vsphere_network.network.id
  adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]

  cluster_domain = var.cluster_domain
  machine_cidr   = var.machine_cidr
  dns_address    = var.public_dns
  gateway        = var.gateway
  ipv4_address   = var.worker1_ips[count.index]
  netmask        = var.netmask
}

module "worker2" {
  source    = "../../modules/rhcos-static"
  count     = length(var.worker2_ips)
  name      = "tcbwkn1${count.index + 1}"
  folder    = "Openshift"
  datastore = data.vsphere_datastore.vsanDatastore.id
  disk_size = 160
  memory    = 32768
  num_cpu   = 8
  ignition  = file(var.worker_ignition_path)

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  template         = data.vsphere_virtual_machine.template.id
  thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned

  network      = data.vsphere_network.network.id
  adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]

  cluster_domain = var.cluster_domain
  machine_cidr   = var.machine_cidr
  dns_address    = var.public_dns
  gateway        = var.gateway
  ipv4_address   = var.worker2_ips[count.index]
  netmask        = var.netmask
}


module "infra" {
  source    = "../../modules/rhcos-static"
  count     = length(var.infra_ips)
  name      = "tcbcinfa0${count.index + 1}"
  folder    = "Openshift"
  datastore = data.vsphere_datastore.vsanDatastore.id
  disk_size = 160
  memory    = 65536
  num_cpu   = 8
  ignition  = file(var.infra_ignition_path)

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  template         = data.vsphere_virtual_machine.template.id
  thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned

  network      = data.vsphere_network.network.id
  adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]

  cluster_domain = var.cluster_domain
  machine_cidr   = var.machine_cidr
  dns_address    = var.public_dns
  gateway        = var.gateway
  ipv4_address   = var.infra_ips[count.index]
  netmask        = var.netmask
}

module "bootstrap" {
  source    = "../../modules/rhcos-static"
  count     = "${var.bootstrap_complete ? 0 : 1}"
  name      = "tcbcbst01"
  folder    = "Openshift"
  datastore = data.vsphere_datastore.vsanDatastore.id
  disk_size = 160
  memory    = 16384
  num_cpu   = 4
  ignition  = file(var.bootstrap_ignition_path)

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  template         = data.vsphere_virtual_machine.template.id
  thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned

  network      = data.vsphere_network.network.id
  adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]

  cluster_domain = var.cluster_domain
  machine_cidr   = var.machine_cidr
  dns_address    = var.public_dns
  gateway        = var.gateway
  ipv4_address   = var.bootstrap_ip
  netmask        = var.netmask
}

module "lb" {
  source = "../../modules/ignition_haproxy"

  ssh_key_file  = [file("~/.ssh/id_rsa.pub")]
  lb_ip_address = var.loadbalancer_ip
  api_backend_addresses = flatten([
    var.bootstrap_ip,
    var.master_ips]
  )
  ingress = var.worker_ips
  ingress1 = var.infra_ips
}

module "lb_vm" {
  source    = "../../modules/rhcos-static"
  count     = 1
  name      = "tcbclb01"
  folder    = "Openshift"
  datastore = data.vsphere_datastore.vsanDatastore.id
  disk_size = 160
  memory    = 8192
  num_cpu   = 4
  ignition  = module.lb.ignition

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  template         = data.vsphere_virtual_machine.template.id
  thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned

  network      = data.vsphere_network.network.id
  adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]

  cluster_domain = var.cluster_domain
  machine_cidr   = var.machine_cidr
  dns_address    = var.public_dns
  gateway        = var.gateway
  ipv4_address   = var.loadbalancer_ip
  netmask        = var.netmask
}

module "coredns" {
  source       = "../../modules/ignition_coredns"
  ssh_key_file = [file("~/.ssh/id_ed25519.pub")]

  cluster_slug    = var.cluster_slug
  cluster_domain  = var.cluster_domain
  coredns_ip      = var.coredns_ip
  bootstrap_ip    = var.bootstrap_ip
  loadbalancer_ip = var.loadbalancer_ip
  master_ips      = var.master_ips
  worker1_ips      = var.worker1_ips
  worker2_ips      = var.worker2_ips
}




module "dns_vm" {
  source    = "../../modules/rhcos-static"
  count     = 1
  name      = "${var.cluster_slug}-coredns"
  folder    = "${var.vmware_folder}/${var.cluster_slug}"
  datastore = data.vsphere_datastore.nvme.id
  disk_size = 60
  memory    = 2048
  num_cpu   = 2
  ignition  = module.coredns.ignition

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  template         = data.vsphere_virtual_machine.template.id
  thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned

  network      = data.vsphere_network.network.id
  adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]

  cluster_domain = var.cluster_domain
  machine_cidr   = var.machine_cidr
  dns_address    = var.public_dns
  gateway        = var.gateway
  ipv4_address   = var.coredns_ip
  netmask        = var.netmask
}
