{ pkgs, ... }:
{
  # virt-manager GUI for connecting to remote libvirt/QEMU hosts.
  # Add remote connections via File > Add Connection (qemu+ssh://user@host/system).
  environment.systemPackages = with pkgs; [
    virt-manager  # GUI for remote libvirt management
    virt-viewer   # SPICE/VNC console for remote VMs
    libvirt       # virsh CLI for scriptable VM management
  ];

  # dconf is required for virt-manager to persist its settings
  programs.dconf.enable = true;
}
