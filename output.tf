resource "time_sleep" "wait_for_dhcp" {
  create_duration = "20s"

  depends_on = [libvirt_domain.example]

  # In terraform-provider-libvirt v0.9.1, autostart attribute is NOT currently 
  # implemented for domains. As it focuses on mapping libvirt XML schemas directly

  # Why autostart Doesn't Work
  # The v0.9.0+ rewrite has a specific design principle:
  # "Models the libvirt XML schemas directly instead of abstracting them, 
  # giving users full access to libvirt features."

  # The problem: autostart is NOT part of the libvirt domain XML schema,
  # it's a separate management API call. 

  # As stated in my earlier explanation, autostart is controlled by creating 
  # symlinks in /etc/libvirt/qemu/autostart/, not through XML configuration.

}

# List only network interfaces
data "libvirt_domain_interface_addresses" "example" {
  domain = libvirt_domain.example.name
  source = "lease" # or any "lease", "agent"

  depends_on = [time_sleep.wait_for_dhcp]
}

output "network_interface" {
  description = "Network interface on the host"
  value       = "ssh ${data.libvirt_domain_interface_addresses.example.interfaces[0].addrs[0].addr} -p ${local.ssh_port}"
}
