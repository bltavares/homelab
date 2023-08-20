
resource "oci_core_virtual_network" "cloud_network" {
  compartment_id = var.oci_profile.compartment
  display_name   = "cloud"

  is_ipv6enabled = true

}

resource "oci_core_subnet" "cloud_subnet" {
  compartment_id = var.oci_profile.compartment
  vcn_id         = oci_core_virtual_network.cloud_network.id

  display_name = "cloud-subnet"


  cidr_block     = cidrsubnet(oci_core_virtual_network.cloud_network.cidr_blocks[0], 8, 0)
  ipv6cidr_block = cidrsubnet(oci_core_virtual_network.cloud_network.ipv6cidr_blocks[0], 8, 0)

  prohibit_internet_ingress  = false
  prohibit_public_ip_on_vnic = false

  dhcp_options_id   = oci_core_dhcp_options.cloud_dhcp.id
  route_table_id    = oci_core_route_table.cloud_route_table.id
  security_list_ids = [oci_core_security_list.cloud_security_list.id]
}

resource "oci_core_dhcp_options" "cloud_dhcp" {
  compartment_id = var.oci_profile.compartment
  vcn_id         = oci_core_virtual_network.cloud_network.id

  display_name = "cloud-dhcp"


  options {
    search_domain_names = [oci_core_virtual_network.cloud_network.vcn_domain_name]
    type                = "SearchDomain"
  }
  options {
    server_type = "VcnLocalPlusInternet"
    type        = "DomainNameServer"
  }
}

resource "oci_core_route_table" "cloud_route_table" {
  compartment_id = var.oci_profile.compartment
  vcn_id         = oci_core_virtual_network.cloud_network.id

  display_name = "cloud-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.cloud_internet_gateway.id
  }
  route_rules {
    destination       = "::/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.cloud_internet_gateway.id
  }
}

resource "oci_core_internet_gateway" "cloud_internet_gateway" {
  compartment_id = var.oci_profile.compartment
  vcn_id         = oci_core_virtual_network.cloud_network.id

  display_name = "cloud-internet-gateway"
  enabled      = true
}

resource "oci_core_security_list" "cloud_security_list" {
  compartment_id = var.oci_profile.compartment
  vcn_id         = oci_core_virtual_network.cloud_network.id
  display_name   = "cloud-security-list"


  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = false
  }

  ingress_security_rules {
    protocol    = "1"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = false

    icmp_options {
      code = -1
      type = 3
    }
  }
  ingress_security_rules {
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    icmp_options {
      code = 4
      type = 3
    }
  }

  egress_security_rules {
    destination      = "::/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = false
  }

  # SSH
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 22
      min = 22
    }
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "::/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 22
      min = 22
    }
  }

  # Web
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 443
      min = 443
    }
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "::/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 443
      min = 443
    }
  }

  # SSB-SHS
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 8008
      min = 8008
    }
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "::/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 8008
      min = 8008
    }
  }
}
