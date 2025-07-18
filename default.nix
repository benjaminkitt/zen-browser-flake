{
  pkgs ? import <nixpkgs> {},
  system ? pkgs.stdenv.hostPlatform.system,
}: let
  mkZen = pkgs: name: system: entry: let
    variant = (builtins.fromJSON (builtins.readFile ./sources.json)).${entry}.${system};

    desktopFile = "zen-${name}.desktop";
  in
    pkgs.callPackage ./package.nix {
      inherit name desktopFile variant;
    };
in rec {
  beta-unwrapped = mkZen pkgs "beta" system "beta";
  twilight-unwrapped = mkZen pkgs "twilight" system "twilight";
  twilight-official-unwrapped = mkZen pkgs "twilight" system "twilight-official";

  beta = if pkgs.stdenv.hostPlatform.isDarwin then beta-unwrapped else pkgs.wrapFirefox beta-unwrapped {};
  twilight = if pkgs.stdenv.hostPlatform.isDarwin then twilight-unwrapped else pkgs.wrapFirefox twilight-unwrapped {};
  twilight-official = if pkgs.stdenv.hostPlatform.isDarwin then twilight-official-unwrapped else pkgs.wrapFirefox twilight-official-unwrapped {};

  default = beta;
}
