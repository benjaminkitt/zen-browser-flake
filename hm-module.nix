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
      package = if pkgs.stdenv.hostPlatform.isDarwin 
        then self.packages.${pkgs.stdenv.system}."${name}-unwrapped"
        else pkgs.wrapFirefox self.packages.${pkgs.stdenv.system}."${name}-unwrapped" {};
      # This does not work, the package can't build using these policies
      policies = lib.mkDefault {
        DisableAppUpdate = true;
        DisableTelemetry = true;
      };
    };
  };
}
