{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        mkhl.direnv
        vscodevim.vim
        ms-vscode-remote.remote-ssh
        ms-vscode.remote-explorer
        ms-vscode-remote.remote-ssh-edit
        ms-vscode-remote.remote-containers
        ms-azuretools.vscode-containers
        anthropic.claude-code
        eamodio.gitlens
        gruntfuggly.todo-tree
      ];
    })
  ];

  programs.nix-ld.enable = true; # Enable VS Code Server install
}
