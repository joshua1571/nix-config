# FIXME: It seems like my gpu gfx1150 is not supported yet in ollama. https://github.com/ollama/ollama/issues/9999
{ username, ... }:
{
  services.ollama = {
    enable = true;
    acceleration = "rocm";
    rocmOverrideGfx = "11.5.0"; # https://github.com/ollama/ollama/blob/main/docs/gpu.mdx
    #user = "${username}";
    #group = "users";
    #home = "/home/${username}/Development/llm/";
    #models = "/home/${username}/Development/llm/models/";
    # Optional: preload models, see https://ollama.com/library
    #loadModels = [
    #  "llama3.2:3b"
    #  "deepseek-r1:1.5b"
    #];
  };
}
