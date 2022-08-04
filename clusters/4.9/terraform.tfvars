## Node IPs
loadbalancer_ip = "10.100.72.17"
bootstrap_ip = "10.100.72.19"
master_ips = ["10.20.11.132", "10.20.11.138", "10.20.11.146"]
infra_ips  = ["10.20.11.133", "10.20.11.139", "10.20.11.147"]
worker1_ips = ["10.20.11.154", "10.20.11.161", "10.20.11.168", "10.20.11.155", "10.20.11.162", "10.20.11.169", "10.20.11.156", "10.20.11.163", "10.20.11.170"]
worker2_ips = ["10.20.11.134", "10.20.11.140", "10.20.11.148", "10.20.11.152", "10.20.11.159", "10.20.11.166", "10.20.11.153", "10.20.11.160", "10.20.11.167"]
coredns_ip = ["10.20.11.143"]

## Cluster configuration
rhcos_template = "rhcos4.9.0"
cluster_slug = "ocp"
cluster_domain = "coj.intra"
machine_cidr = " 10.100.72.0/24"
netmask ="255.255.255.0"

## DNS
public_dns = "10.20.11.143" # e.g. 1.1.1.1
gateway = "10.100.72.254"

## Ignition paths
## Expects `openshift-install create ignition-configs` to have been run
## probably via generate-configs.sh
bootstrap_ignition_path = "../../openshift/bootstrap.ign"
master_ignition_path = "../../openshift/master.ign"
worker_ignition_path = "../../openshift/worker.ign"
infra_ignition_path = "../../openshift/worker.ign"

