{
  system,
  inputs,
  ...
}:
{
  environment.systemPackages = [
    inputs.agenix.packages."${system}".default
  ];
}
