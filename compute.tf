###############################################
### This is the compute node (resource)
###############################################
resource "oci_core_instance" "ClusterCompute" {
  count               = "${length(var.InstanceADIndex)}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.InstanceADIndex[count.index] - 1], "name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "compute${format("%03d", count.index+1)}"
  shape               = "${var.ComputeShapes[count.index]}"

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.ClusterSubnet.*.id[index(var.ADS, var.InstanceADIndex[count.index])]}"
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "compute${format("%03d", count.index+1)}"
  }

  source_details {
    source_type = "image"
    source_id   = "${lookup(var.ComputeImageOCID[var.ComputeShapes[count.index]], var.region)}"

    # Apply this to set the size of the boot volume that's created for this instance.
    # Otherwise, the default boot volume size of the image is used.
    # This should only be specified when source_type is set to "image".
    #boot_volume_size_in_gbs = "60"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}${data.tls_public_key.oci_public_key.public_key_openssh}"
    user_data           = "${base64encode(file(var.BootStrapFile))}"
  }

  timeouts {
    create = "60m"
  }

  freeform_tags = {
    "cluster"  = "${var.ClusterNameTag}"
    "nodetype" = "compute"
  }
}

###############################################
### This is the master node (resource)
###############################################
resource "oci_core_instance" "ClusterManagement" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.ManagementAD - 1], "name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "mgmt"
  shape               = "${var.ManagementShape}"

  create_vnic_details {
    # ManagementAD
    #subnet_id        = "${oci_core_subnet.ClusterSubnet.id}"
    subnet_id = "${oci_core_subnet.ClusterSubnet.*.id[index(var.ADS, var.ManagementAD)]}"

    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "mgmt"
  }

  source_details {
    source_type = "image"
    source_id   = "${var.ManagementImageOCID[var.region]}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}${data.tls_public_key.oci_public_key.public_key_openssh}"
    user_data           = "${base64encode(file(var.BootStrapFile))}"
  }

  timeouts {
    create = "60m"
  }

  freeform_tags = {
    "cluster"  = "${var.ClusterNameTag}"
    "nodetype" = "mgmt"
  }
}



###############################################
### This is the script for the master node 
###############################################
resource "null_resource" "copy_in_setup_data_mgmt" {
  depends_on = ["oci_core_instance.ClusterManagement"]

  triggers {
     cluster_instance = "${oci_core_instance.ClusterManagement.id}"
#     cluster_instance0 = "${oci_core_instance.ClusterCompute.0}"
#     cluster_instance1 = "${oci_core_instance.ClusterCompute.1}"
#     cluster_instance2 = "${oci_core_instance.ClusterCompute.2}"
#     cluster_instance3 = "${oci_core_instance.ClusterCompute.3}"
#     cluster_instance4 = "${oci_core_instance.ClusterCompute.4}"
#     cluster_instance5 = "${oci_core_instance.ClusterCompute.5}"
#     cluster_instance6 = "${oci_core_instance.ClusterCompute.6}"
  }

  provisioner "file" {
    destination = "/home/opc/config"
    content = <<EOF
[DEFAULT]
user=${var.user_ocid}
fingerprint=${var.fingerprint}
key_file=/home/slurm/.oci/oci_api_key.pem
tenancy=${var.tenancy_ocid}
region=${var.region}
EOF

    connection {
      timeout = "15m"
      host = "${oci_core_instance.ClusterManagement.*.public_ip}"
      user = "opc"
      private_key = "${file(var.private_key_path)}"
      agent = false
    }
  }

  provisioner "file" {
    destination = "/home/opc/oci_api_key.pem"
    source = "${var.private_key_path}"

    connection {
      timeout = "15m"
      host = "${oci_core_instance.ClusterManagement.*.public_ip}"
      user = "opc"
      private_key = "${file(var.private_key_path)}"
      agent = false
    }
  }

  provisioner "file" {
    destination = "/home/opc/nodes.yaml"
    content = <<EOF
---
names: ["${join("\", \"", oci_core_instance.ClusterCompute.*.display_name)}"]
shapes: ["${join("\", \"", var.ComputeShapes)}"]
EOF

    connection {
      timeout = "15m"
      host = "${oci_core_instance.ClusterManagement.*.public_ip}"
      user = "opc"
      private_key = "${file(var.private_key_path)}"
      agent = false
    }
  }

  provisioner "file" {
    destination = "/home/opc/shapes.yaml"
    source = "files/shapes.yaml"

    connection {
      timeout = "15m"
      host = "${oci_core_instance.ClusterManagement.*.public_ip}"
      user = "opc"
      private_key = "${file(var.private_key_path)}"
      agent = false
    }
  }

  provisioner "file" {
    destination = "/home/opc/hosts"
    content = <<EOF
[MPI_CLUSTER]
${oci_core_instance.ClusterManagement.display_name}          ${oci_core_instance.ClusterManagement.*.private_ip[count.index]}
${join("\n", oci_core_instance.ClusterCompute.*.display_name)}    ${oci_core_instance.ClusterCompute.*.private_ip[count.index]}
EOF

    connection {
      timeout = "15m"
      host = "${oci_core_instance.ClusterManagement.*.public_ip}"
      user = "opc"
      private_key = "${file(var.private_key_path)}"
      agent = false
    }
  }

  provisioner "file" {
    destination = "/home/opc/hostsE"
    content = <<EOF
/home/opc/Bench    ${oci_core_instance.ClusterCompute.*.private_ip[count.index]}(rw,sync,no_root_squash,no_all_squash)
/home/opc/hpl      ${oci_core_instance.ClusterCompute.*.private_ip[count.index]}(rw,sync,no_root_squash,no_all_squash)
/tmp               ${oci_core_instance.ClusterCompute.*.private_ip[count.index]}(rw,sync,no_root_squash,no_all_squash)
EOF

    connection {
      timeout = "15m"
      host = "${oci_core_instance.ClusterManagement.*.public_ip}"
      user = "opc"
      private_key = "${file(var.private_key_path)}"
      agent = false
    }
  }
  
  provisioner "file" {
    destination = "/home/opc/hostsP"
    content = <<EOF
[IP_LIST]
${oci_core_instance.ClusterManagement.*.public_ip[count.index]}
${oci_core_instance.ClusterCompute.*.public_ip[count.index]}
EOF

    connection {
      timeout = "15m"
      host = "${oci_core_instance.ClusterManagement.*.public_ip}"
      user = "opc"
      private_key = "${file(var.private_key_path)}"
      agent = false
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo make ~/Bench",
      "sudo yum install -y ansible git",
      "sudo yum install gcc-gfortran gcc-c++ openmpi openmpi-devel -y",
      "cd /usr/local",
      "sudo git clone https://github.com/xianyi/OpenBLAS",
      "cd OpenBLAS",
      "sudo make",
      "sudo make install PREFIX=/usr/lib64/openblas",
      "sudo echo 'export PATH=$PATH:/usr/lib64/openmpi/bin' >> ~/.bashrc",
      "sudo echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib64/openmpi/lib' >> ~/.bashrc",
      "sudo echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib64/openblas/lib' >> ~/.bashrc",
      "source ~/.bashrc",
      "sleep 20"
    ]

    connection {
        timeout = "15m"
        host = "${oci_core_instance.ClusterManagement.*.public_ip}"
        user = "opc"
        private_key = "${file(var.private_key_path)}"
        agent = false
    }
  }
}

###############################################
### This is the script for the compute node 
###############################################
resource "null_resource" "copy_in_setup_data_compute" {
  count = "${length(var.InstanceADIndex)}"
  depends_on = ["oci_core_instance.ClusterCompute"]

  triggers {
     cluster_instanceM = "${oci_core_instance.ClusterManagement.id}"
#     clusterGroup=
     tonto=0
     cluster_instance0 = "${oci_core_instance.ClusterCompute.*.tonto}"
#     cluster_instance1 = "${oci_core_instance.ClusterCompute.1}"
#     cluster_instance2 = "${oci_core_instance.ClusterCompute.2}"
#     cluster_instance3 = "${oci_core_instance.ClusterCompute.3}"
#     cluster_instance4 = "${oci_core_instance.ClusterCompute.4}"
#     cluster_instance5 = "${oci_core_instance.ClusterCompute.5}"
#     cluster_instance6 = "${oci_core_instance.ClusterCompute.6}"
  }

  provisioner "file" {
    destination = "/home/opc/hosts"
    content = <<EOF
[MPI_CLUSTER]
${oci_core_instance.ClusterManagement.display_name}          ${oci_core_instance.ClusterManagement.*.private_ip[count.index]}
${join("\n", oci_core_instance.ClusterCompute.*.display_name)}    ${oci_core_instance.ClusterCompute.*.private_ip[count.index]}
EOF

    connection {
      timeout = "15m"
      host = "${oci_core_instance.ClusterCompute.*.public_ip[count.index]}"
      user = "opc"
      private_key = "${file(var.private_key_path)}"
      agent = false
    }
  }

  provisioner "remote-exec" {
    inline = [
      "make ~/Bench",
      "sudo yum install -y ansible git",
      "sudo yum install gcc-gfortran gcc-c++ openmpi openmpi-devel -y",
      "cd /usr/local",
      "sudo git clone https://github.com/xianyi/OpenBLAS",
      "cd OpenBLAS",
      "sudo make",
      "sudo make install PREFIX=/usr/lib64/openblas",
      "sudo echo 'export PATH=$PATH:/usr/lib64/openmpi/bin' >> ~/.bashrc",
      "sudo echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib64/openmpi/lib' >> ~/.bashrc",
      "sudo echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib64/openblas/lib' >> ~/.bashrc",
      "source ~/.bashrc",
      "sleep 20"
    ]

    connection {
        timeout = "15m"
        host = "${oci_core_instance.ClusterCompute.*.public_ip[count.index]}"
        user = "opc"
        private_key = "${file(var.private_key_path)}"
        agent = false
    }
  }
}
