{ pkgs, ... }: {
  programs = {
    bash = {
      enable = true;
      enableCompletion = true;

      shellAliases = {
        ll = "eza -l -o -g";
        lla = "eza -l -o -g -a";
        grep = "rg --color=auto";
        gits = "git status";
        gitd = "git diff";
        tput = "trash-put";
        tlist = "trash-list";
        trestore = "trash-restore";
      };
    };
  };
}
