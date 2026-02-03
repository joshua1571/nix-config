{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [

    ###text to text
    llama-cpp-rocm
    #llama-cpp-vulkan

    ###text to image
    stable-diffusion-cpp-rocm
    #stable-diffusion-cpp-vulkan

    ###speech to text
    #openai-whisper
  ];
}
