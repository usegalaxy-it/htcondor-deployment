# has to be cahged
variable "public_key" {
  type = map(any)
  default = {
    name       = "htcondor-cluster-test"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCpobhtTAVUFOgJo+WAYdGhHwmAdEL9JuE15iUZ2d098yZnhAJ2NkfeCPWtL3dsUYEAAtPqH2QKlgHtUR6aPQRabMPCcntwa+x1S2wXN457xtnnKZo/N8yC1bjhry6wzqqNwbyo4lKqJgsS3AIMQuPDBFvidQg4PleQfisv1uZvL9+9/mm/DIJ5Sa5t5JR2RIajY1agAvgsS3yZzgCFAVi45UlAICAFnYQwCbpF2Y9rXSG9MZtUecg3m57CU3zxCH7+1zdt6NBEINlZYR3v0NQ60o4OFbHKvHDBdKfutz/rT6H5EjULsWScwkpi+L4V5SmdBUk1JobztacHiYgTj/pJ centos@pulsar-control-vm.garr.cloud.pa"
  }
}

variable "public_network" {
  type = map(any)
  default = {
    name = "floating-ip"
  }
}

variable "private_network" {
  type = map(any)
  default = {
    name        = "elixir-VM-net"
    subnet_name = "elixir-VM-subnet"
    cidr4       = "192.168.208.0/22"
  }
}

# uncomment `sensitive = true` if you don't want to expose these values in terraform state file
# this var should be specified in terraform.tfvars
variable "pvt_key" {
  # sensitive = true
}

# this var should be specified in terraform.tfvars
variable "condor_pass" {
  # sensitive = true
}

variable "nfs" {
  type = map(any)
  default = {
    name        = "nfs-htcondor"
    description = "nfs volume for htcondor cluster"
    disk_size   = 300
    volume_type = "__DEFAULT__"
  }
}

variable "flavors" {
  type = map(any)
  default = {
    "central-manager" = "m1.small"
    "nfs-server"      = "m1.medium"
    "exec-node"       = "m1.xlarge"
  }
}

variable "exec_node_count" {
  type    = number
  default = 2
}

variable "image" {
  type = map(any)
  default = {
    name             = "Rocky-9-GenericCloud.latest.x86_64"
    image_source_url = "https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2"
    container_format = "bare"
    disk_format      = "qcow2"
    description      = "downloaded from https://download.rockylinux.org"
  }
}

variable "name_prefix" {
  type    = string
  default = "htcondor-"
}

variable "secgroups_cm" {
  type = list(any)
  default = [
    "htcondor-public-ssh",
    "htcondor-ingress-private",
    "htcondor-egress-public",
  ]
}

variable "secgroups" {
  type = list(any)
  default = [
    "htcondor-ingress-private",
    "htcondor-egress-public",
  ]
}

variable "domain_name" {
  type    = string
  default = "htcondor"
}

variable "ssh-port" {
  type    = string
  default = "22"
}


