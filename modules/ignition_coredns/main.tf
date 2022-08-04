data "ignition_user" "core" {
  name                = "core"
  ssh_authorized_keys = var.ssh_key_file
}

data "ignition_systemd_unit" "coredns" {
  name    = "coredns.service"
  content = file("${path.module}/files/coredns.service")
}

data "ignition_file" "http_proxy" {
  path = "/etc/profile.d/http_proxy.sh"
  mode = "775"
  content {
    content = file("${path.module}/files/http_proxy.sh")
  }
}

data "ignition_file" "corefile" {
  path = "/opt/coredns/Corefile"
  mode = "420" // 0644
  content {
    content = file("${path.module}/files/Corefile")
  }
}

data "ignition_file" "ocp_customs_th" {
  path = "/opt/coredns/ocp.customs.th.db"
  mode = "420" // 0644
  content {
    content = templatefile("${path.module}/files/ocp.customs.th.db.tmpl", {
      cluster_slug    = var.cluster_slug,
      cluster_domain  = var.cluster_domain
    })
  }
}

data "ignition_file" "ocp_reverse" {
  path = "/opt/coredns/ocp.reverse"
  mode = "420" // 0644
  content {
    content = templatefile("${path.module}/files/ocp.reverse", {
      cluster_slug    = var.cluster_slug,
      cluster_domain  = var.cluster_domain
    })
  }
}

# the final output
data "ignition_config" "coredns" {
  users   = [data.ignition_user.core.rendered]
  files   = [data.ignition_file.http_proxy.rendered, data.ignition_file.corefile.rendered, data.ignition_file.ocp_customs_th.rendered, data.ignition_file.ocp_reverse.rendered]
  systemd = [data.ignition_systemd_unit.coredns.rendered]
}
