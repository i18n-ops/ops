{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    zsh
    git
    curl
    wget
  ];
}