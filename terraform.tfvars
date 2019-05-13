### Authentication details
tenancy_ocid = "ocid1.tenancy.oc1..aaaaaaaacr6j4eeqkro4mu7s3cn273d7gacbv72umu7caa2keelbzbil3clq"
user_ocid = "ocid1.user.oc1..aaaaaaaastba2wpfl2rsyvptgfhygpkqpyeeggmqclfhxzf7an5pdn5cpbdq"
fingerprint = "49:02:d7:39:03:2a:81:91:54:f2:10:71:9c:4b:4b:19"
private_key_path = "/home/opc/.oci/oci_api_key.pem"

### Region
region = "us-ashburn-1"
ADS = ["3"]

### Compartment
compartment_ocid = "ocid1.tenancy.oc1..aaaaaaaacr6j4eeqkro4mu7s3cn273d7gacbv72umu7caa2keelbzbil3clq"

### Public/private keys used on the instance
ssh_public_key = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhEnkl4i9U8UCZiUPFw+65KilnZ8xp9FyIUT6rdVX4CWkYQnlhjRfNSaY/tMf4Jhb3cIGnBxZeTtEKGWRZVq6bSX2SGeU+Eg8lQFTzq4eHYS2OWNL400FPUHmz7utKhTuhzfBzlb2ZFM66/hZ/ssGUmlllJDZnKO0xk9t1dWWGoltrwbJA3EW4jTj/yrzillkHfP6/g+vm3WFVpLiFf7v6v5RXOs9zgfNJZcVZlvgYZzzjmSFaKLJtjBKS8H/5njiyvPJF0+9O/1EWjpvpud5AfhneU7DG3fExRzh+XKpxQwwVvLY9zR4kmDx8QYpCYvjXlaEJlQxKYc5lzNV8JftP
EOF

ClusterNameTag = "odycluster"

InstanceADIndex = ["3","3"]
ManagementShape = "VM.Standard.E2.1"
ComputeShapes = ["VM.Standard.E2.1","VM.Standard.E2.1"]
ComputeImageOCID = {
  VM.Standard.E2.1 = {
    // See https://docs.cloud.oracle.com/iaas/images/
    // Oracle-Linux-7.6-2018.11.19-0
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaa77atxnaou5ykurakjrjybn4efaa7w3tmg47oo3b4v6e4jldkzzlq"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaarsu56scul4muz3sqbptvykipy2rn6re3wzdjvncgcpgqt5cp3wja"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaajscyriqmukax7k5tgayq6g26lolscurrcphc4bofty6i6gmq2x2q"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaaw2jelcbmlkzu2vde7t6wyanqzrn5xl7likly5xbputixs3gdj6pa"
#    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa2rvnnmdz6ewn4pozatb2l6sjtpqpbgiqrilfh3b4ee7salrwy3kq"
#    uk-london-1 = "ocid1.image.oc1.uk-london-1.aaaaaaaaikjrglbnzkvlkiltzobfvtxmqctoho3tmdcwopnqnoolmwbsk3za"
  }
}
ManagementImageOCID = {
  // See https://docs.cloud.oracle.com/iaas/images/
  // Oracle-Linux-7.6-2018.11.19-0
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaa77atxnaou5ykurakjrjybn4efaa7w3tmg47oo3b4v6e4jldkzzlq"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaarsu56scul4muz3sqbptvykipy2rn6re3wzdjvncgcpgqt5cp3wja"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaajscyriqmukax7k5tgayq6g26lolscurrcphc4bofty6i6gmq2x2q"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaaw2jelcbmlkzu2vde7t6wyanqzrn5xl7likly5xbputixs3gdj6pa"
#  eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa2rvnnmdz6ewn4pozatb2l6sjtpqpbgiqrilfh3b4ee7salrwy3kq"
#  uk-london-1 = "ocid1.image.oc1.uk-london-1.aaaaaaaaikjrglbnzkvlkiltzobfvtxmqctoho3tmdcwopnqnoolmwbsk3za"
}
