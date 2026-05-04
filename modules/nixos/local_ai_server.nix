{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    llama-cpp-vulkan
    amdgpu_top
  ];

  services = {
    ollama = {
      enable = true;
      package = pkgs.ollama-vulkan;
      loadModels = [ "qwen3.5:9b" ];
      host = "0.0.0.0";
      port = 11434;
      environmentVariables = {
        OLLAMA_CONTEXT_LENGTH = "65536";
        OLLAMA_KEEP_ALIVE = "30m";
        OLLAMA_HOME = "/home/$username/.ollama";
      };
    };

    open-webui = {
      enable = true;
      port = 8080;
      environment = {
        OLLAMA_BASE_URL = "http://127.0.0.1:11434";
        WEBUI_AUTH = "False";
      };
    };
  };
}
