{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ###text to text
    #llama-cpp-rocm #https://lunnova.dev/articles/rocm-711-you-can-not-build/
    llama-cpp-vulkan

    ###text to image
    #stable-diffusion-cpp-rocm #https://lunnova.dev/articles/rocm-711-you-can-not-build/
    #stable-diffusion-cpp-vulkan

    ###speech to text
    #openai-whisper
  ];
}
