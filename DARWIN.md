# Darwin (macOS) Support

This flake now supports Darwin (macOS) on both Intel and Apple Silicon systems.

## Supported Systems

- `aarch64-darwin` (Apple Silicon)
- `x86_64-darwin` (Intel)

## Installation

### Direct Installation

```bash
# Build and run beta version
nix run github:benjaminkitt/zen-browser-flake#beta

# Build and run twilight version
nix run github:benjaminkitt/zen-browser-flake#twilight

# Install to profile
nix profile install github:benjaminkitt/zen-browser-flake#beta
```

### Home Manager Integration

Add the flake to your home-manager configuration:

```nix
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
    homeConfigurations."your-username" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin; # or x86_64-darwin
      modules = [
        zen-browser.homeModules.beta # or twilight, twilight-official
        {
          home.username = "your-username";
          home.homeDirectory = "/Users/your-username";
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
```

Then apply the configuration:

```bash
home-manager switch --flake .#your-username
```

## Configuration

The home-manager module supports the same configuration options as the Firefox module, including:

- Browser policies
- Extensions
- Bookmarks
- Search engines
- And more

Configuration files are stored in `~/Library/Application Support/Zen` on macOS.

## Available Variants

- `beta`: The latest beta release
- `twilight`: Development builds
- `twilight-official`: Official twilight builds

## Notes

- The macOS version uses the universal binary that supports both Intel and Apple Silicon
- No wrapper is needed on Darwin - the app bundle is used directly
- The browser integrates with macOS system preferences and notifications