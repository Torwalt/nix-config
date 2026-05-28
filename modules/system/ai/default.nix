{ pkgs, ... }: {
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;

    loadModels = [ "qwen2.5-coder:7b" "llama3.2:3b" ];
  };

}
