data "template_cloudinit_config" "rancherserver-cloudinit" {
  part {
    content_type = "text/cloud-config"
    content      = "hostname: ${var.prefix}-rancherserver\nmanage_etc_hosts: true"
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.userdata_server.rendered
  }
}

resource "aws_instance" "rancherserver" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.type
  key_name        = var.ssh_key_name
  user_data       = data.template_cloudinit_config.rancherserver-cloudinit.rendered
  subnet_id       = var.rancher_subnet
  tags = {
    Name = "${var.prefix}-rancherserver"
  }
}

data "template_cloudinit_config" "rancheragent-all-cloudinit" {
  count = var.count_agent_all_nodes

  part {
    content_type = "text/cloud-config"
    content      = "hostname: ${var.prefix}-rancheragent-${count.index}-all\nmanage_etc_hosts: true"
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.userdata_agent.rendered
  }
}

resource "aws_instance" "rancheragent-all" {
  count           = var.count_agent_all_nodes
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.type
  key_name        = var.ssh_key_name
  subnet_id       = var.rancher_subnet
  user_data       = data.template_cloudinit_config.rancheragent-all-cloudinit[count.index].rendered

  tags = {
    Name = "${var.prefix}-rancheragent-${count.index}-all"
  }
}

data "template_cloudinit_config" "rancheragent-etcd-cloudinit" {
  count = var.count_agent_etcd_nodes

  part {
    content_type = "text/cloud-config"
    content      = "hostname: ${var.prefix}-rancheragent-${count.index}-etcd\nmanage_etc_hosts: true"
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.userdata_agent.rendered
  }
}

resource "aws_instance" "rancheragent-etcd" {
  count           = var.count_agent_etcd_nodes
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.type
  key_name        = var.ssh_key_name
  user_data       = data.template_cloudinit_config.rancheragent-etcd-cloudinit[count.index].rendered
  subnet_id       = var.rancher_subnet
  tags = {
    Name = "${var.prefix}-rancheragent-${count.index}-etcd"
  }
}

data "template_cloudinit_config" "rancheragent-controlplane-cloudinit" {
  count = var.count_agent_controlplane_nodes

  part {
    content_type = "text/cloud-config"
    content      = "hostname: ${var.prefix}-rancheragent-${count.index}-controlplane\nmanage_etc_hosts: true"
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.userdata_agent.rendered
  }
}

resource "aws_instance" "rancheragent-controlplane" {
  count           = var.count_agent_controlplane_nodes
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.type
  key_name        = var.ssh_key_name
  user_data       = data.template_cloudinit_config.rancheragent-controlplane-cloudinit[count.index].rendered
  subnet_id       = var.rancher_subnet
  tags = {
    Name = "${var.prefix}-rancheragent-${count.index}-controlplane"
  }
}

data "template_cloudinit_config" "rancheragent-worker-cloudinit" {
  count = var.count_agent_worker_nodes

  part {
    content_type = "text/cloud-config"
    content      = "hostname: ${var.prefix}-rancheragent-${count.index}-worker\nmanage_etc_hosts: true"
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.userdata_agent.rendered
  }
}

resource "aws_instance" "rancheragent-worker" {
  count           = var.count_agent_worker_nodes
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.type
  key_name        = var.ssh_key_name
  user_data       = data.template_cloudinit_config.rancheragent-worker-cloudinit[count.index].rendered
  subnet_id       = var.rancher_subnet
  tags = {
    Name = "${var.prefix}-rancheragent-${count.index}-worker"
  }
}

data "template_file" "userdata_server" {
  template = file("rancher-server/files/userdata_server")

  vars = {
    admin_password        = var.admin_password
    cluster_name          = var.cluster_name
    docker_version_server = var.docker_version_server
    rancher_version       = var.rancher_version
  }
}

data "template_file" "userdata_agent" {
  template = file("rancher-server/files/userdata_agent")

  vars = {
    admin_password       = var.admin_password
    cluster_name         = var.cluster_name
    docker_version_agent = var.docker_version_agent
    rancher_version      = var.rancher_version
    server_address       = aws_instance.rancherserver.public_ip
  }
}

output "rancher-url" {
  value = ["https://${aws_instance.rancherserver.public_ip}"]
}

