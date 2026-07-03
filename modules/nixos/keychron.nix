# udev rule so the Keychron Launcher (WebHID) can talk to the keyboard.
# https://blaise.ca/blog/2025/12/31/howto-get-the-keychron-launcher-working-in-debian-gnu-linux/
#
# launcher.keychron.com programs the board over WebHID, which needs write
# access to the hidraw device. TAG+="uaccess" grants the active seat user
# access via logind ACLs; MODE/GROUP are a belt-and-suspenders fallback
# (jrh's primary group is `users`).
#
# Vendor/product IDs below are for the Keychron K10 HE. Confirm yours with:
#   lsusb | grep -i keychron
# To cover every Keychron device / connection mode, drop the idProduct match
# and key on ATTRS{idVendor}=="3434" alone.
_: {
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", MODE="0660", GROUP="users", TAG+="uaccess"
  '';
}
