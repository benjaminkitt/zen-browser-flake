{
  name,
  variant,
  desktopFile,
  
  # Core Firefox wrapper parameters
  policies ? {},
  cfg ? {},
  extraPolicies ? {},
  extraPrefs ? "",
  extraPrefsFiles ? [],
  extraPoliciesFiles ? [],
  
  # Security and integration
  pkcs11Modules ? [],
  nativeMessagingHosts ? [],
  
  # Extensions
  nixExtensions ? null,
  
  # System integration
  useGlvnd ? (!stdenv.hostPlatform.isDarwin),
  hasMozSystemDirPatch ? false,
  
  # Feature flags
  pipewireSupport ? false,
  ffmpegSupport ? true,
  gssSupport ? true,
  enableAdobeFlash ? false,
  enableGnomeExtensions ? false,
  
  # Build configuration
  allowAddonSideload ? false,
  requireSigning ? true,
  
  # Branding
  branding ? null,
  
  # UI and naming
  icon ? applicationName,
  wmClass ? applicationName,
  nameSuffix ? "",
  
  # System dependencies
  lib,
  stdenv,
  config,
  wrapGAppsHook3,
  autoPatchelfHook,
  alsa-lib,
  curl,
  dbus-glib,
  gtk3,
  libXtst,
  libva,
  libGL,
  pciutils,
  pipewire,
  adwaita-icon-theme,
  writeText,
  patchelfUnstable, # have to use patchelfUnstable to support --no-clobber-old-sections
  undmg,
  applicationName ?
    (if stdenv.hostPlatform.isDarwin
     then "Zen"
     else "Zen Browser" + (
       if name == "beta"
       then " (Beta)"
       else if name == "twilight"
       then " (Twilight)"
       else if name == "twilight-official"
       then " (Twilight)"
       else ""
     )),
}: let
  binaryName = "zen-${name}";

  libName = "zen-bin-${variant.version}";

  mozillaPlatforms = {
    x86_64-linux = "linux-x86_64";
    aarch64-linux = "linux-aarch64";
    aarch64-darwin = "macos-universal";
    x86_64-darwin = "macos-universal";
  };

  firefoxPolicies =
    (cfg.policies or {})
    // (config.firefox.policies or {})
    // policies
    // extraPolicies;

  policiesJson = writeText "firefox-policies.json" (builtins.toJSON {policies = firefoxPolicies;});

  pname = "zen-${name}-unwrapped";
in
  stdenv.mkDerivation {
    inherit pname;
    inherit (variant) version;

    src = if stdenv.hostPlatform.isDarwin
      then builtins.fetchurl {inherit (variant) url sha256;}
      else builtins.fetchTarball {inherit (variant) url sha256;};
    desktopSrc = ./assets/desktop;

    nativeBuildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
      undmg
    ] ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
      wrapGAppsHook3
      autoPatchelfHook
      patchelfUnstable
    ];
    buildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [
      gtk3
      adwaita-icon-theme
      alsa-lib
      dbus-glib
      libXtst
    ];
    runtimeDependencies = lib.optionals (!stdenv.hostPlatform.isDarwin) [
      curl
      libva.out
      pciutils
      libGL
    ];
    appendRunpaths = lib.optionals (!stdenv.hostPlatform.isDarwin) [
      "${libGL}/lib"
      "${pipewire}/lib"
    ];
    # Firefox uses "relrhack" to manually process relocations from a fixed offset
    patchelfFlags = lib.optionals (!stdenv.hostPlatform.isDarwin) ["--no-clobber-old-sections"];

    unpackPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
      undmg $src
      sourceRoot="."
    '';

    preFixup = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
      gappsWrapperArgs+=(
        --add-flags "--name=''${MOZ_APP_LAUNCHER:-${binaryName}}"
      )
    '';

    installPhase = if stdenv.hostPlatform.isDarwin then ''
      mkdir -p "$out/Applications"
      cp -r "Zen.app" "$out/Applications/"
      
      # Install Firefox policies for configuration
      mkdir -p "$out/Applications/Zen.app/Contents/Resources/distribution"
      ln -s ${policiesJson} "$out/Applications/Zen.app/Contents/Resources/distribution/policies.json"
      
      mkdir -p "$out/bin"
      ln -s "$out/Applications/Zen.app/Contents/MacOS/${binaryName}" "$out/bin/${binaryName}"
      ln -s "$out/bin/${binaryName}" "$out/bin/zen"
    '' else ''
      mkdir -p "$prefix/lib/${libName}"
      cp -r "$src"/* "$prefix/lib/${libName}"

      mkdir -p "$out/bin"
      ln -s "$prefix/lib/${libName}/zen" "$out/bin/${binaryName}"
      # ! twilight and beta could collide if both are installed
      ln -s "$out/bin/${binaryName}" "$out/bin/zen"

      install -D $desktopSrc/${desktopFile} $out/share/applications/${desktopFile}

      mkdir -p "$out/lib/${libName}/distribution"
      ln -s ${policiesJson} "$out/lib/${libName}/distribution/policies.json"

      install -D $src/browser/chrome/icons/default/default16.png $out/share/icons/hicolor/16x16/apps/zen-${name}.png
      install -D $src/browser/chrome/icons/default/default32.png $out/share/icons/hicolor/32x32/apps/zen-${name}.png
      install -D $src/browser/chrome/icons/default/default48.png $out/share/icons/hicolor/48x48/apps/zen-${name}.png
      install -D $src/browser/chrome/icons/default/default64.png $out/share/icons/hicolor/64x64/apps/zen-${name}.png
      install -D $src/browser/chrome/icons/default/default128.png $out/share/icons/hicolor/128x128/apps/zen-${name}.png
    '';

    passthru = {
      inherit applicationName binaryName libName;
      ffmpegSupport = true;
      gssSupport = true;
      gtk3 = gtk3;
    };

    meta = {
      inherit desktopFile;
      description = "Experience tranquillity while browsing the web without people tracking you!";
      homepage = "https://zen-browser.app";
      downloadPage = "https://zen-browser.app/download/";
      changelog = "https://github.com/zen-browser/desktop/releases";
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      platforms = builtins.attrNames mozillaPlatforms;
      broken = false;
      hydraPlatforms = [];
      mainProgram = binaryName;
    };
  }
