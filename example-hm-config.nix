# Example home-manager configuration for Zen Browser on Darwin
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:benjaminkitt/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, zen-browser, ... }: {
    homeConfigurations."username" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      modules = [
        zen-browser.homeModules.beta
        {
          home.username = "username";
          home.homeDirectory = "/Users/username";
          home.stateVersion = "23.11";
          
          programs.zen-browser = {
            enable = true;
            policies = {
              DisableAppUpdate = true;
              DisableTelemetry = true;
              DefaultDownloadDirectory = "\${home}/Downloads";
            };
          };
        }
      ];
    };
  };
}
