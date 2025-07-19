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
          configPath = "Library/Application Support/zen";
        };
      };
    })
  ];

  config = lib.mkIf config.programs.zen-browser.enable {
    programs.zen-browser = {
      # Explicitly provide the package since mkFirefoxModule can't find it automatically
      package = self.packages.${pkgs.stdenv.system}."${name}";
      policies = lib.mkDefault {
        DisableAppUpdate = true;
        DisableTelemetry = true;
      };
    };
  };
}
