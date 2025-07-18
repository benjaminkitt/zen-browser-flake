{
  home-manager,
  self,
  name,
}: {
  config,
  pkgs,
  lib,
  ...
}: let
  applicationName = "Zen Browser";
  modulePath = [
    "programs"
    "zen-browser"
  ];

  mkFirefoxModule = import "${home-manager.outPath}/modules/programs/firefox/mkFirefoxModule.nix";
in {
  imports = [
    (mkFirefoxModule {
      inherit modulePath;
      name = applicationName;
      wrappedPackageName = "zen-${name}";
      unwrappedPackageName = "zen-${name}-unwrapped";
      visible = true;
      platforms = {
        linux = {
          vendorPath = ".zen";
          configPath = ".zen";
        };
        darwin = {
          configPath = "Library/Application Support/Zen";
        };
      };
    })
  ];

  config = lib.mkIf config.programs.zen-browser.enable {
    programs.zen-browser = {
      # Let mkFirefoxModule handle the package assignment automatically
      policies = lib.mkDefault {
        DisableAppUpdate = true;
        DisableTelemetry = true;
      };
    };
    
    # Make the packages available to mkFirefoxModule
    nixpkgs.overlays = [
      (final: prev: {
        "zen-${name}" = self.packages.${pkgs.stdenv.system}."${name}";
        "zen-${name}-unwrapped" = self.packages.${pkgs.stdenv.system}."${name}-unwrapped";
      })
    ];
  };
}
