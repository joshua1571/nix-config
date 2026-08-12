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
        anthropic.claude-code
        eamodio.gitlens
        gruntfuggly.todo-tree
        #docker.docker
        #ms-vscode-remote.vscode-remote-extensionpack
      ];
    })
  ];

  programs.nix-ld.enable = true; # Enable VS Code Server install
}
