{
  programs.nixvim.plugins = {
    hardtime = {
      enable = true;
      settings = {
        enabled = true;
        #disableMouse = false;
        #restrictionMode = "hint";
        #hint = true;
        #maxCount = 40;
        #maxTime = 1000;
      };
    };
  };
}
