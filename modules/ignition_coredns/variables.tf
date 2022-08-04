variable "ssh_key_file" {
  type = list(string)
}

variable "cluster_slug" {
  type = string
}

variable "cluster_domain" {
  type = string
}

variable "coredns_ip" {
  type = string
}


variable "bootstrap_ip" {
  type = string
}

variable "master_ips" {
  type = list(string)
}

variable "worker_CP4A_ips" {
  type    = list(string)
}

variable "worker_CP4I_ips" {
  type    = list(string)
}

variable "worker_CP4MCM_ips" {
  type    = list(string)
}

variable "infra_ips" {
  type = list(string)
}



