# Any further configuration will be tied to my firefox account
{ pkgs, ... }: {
  programs = { firefox = { enable = true; }; };
}
