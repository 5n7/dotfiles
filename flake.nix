{
  description = "shunta's macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    codex-cli-nix = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    herdr = {
      url = "github:herdrdev/herdr";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    herdr-extensions = {
      url = "github:5n7/herdr-extensions";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Third-party plugin sources are pinned as non-flake inputs and built in
    # modules/home/herdr/plugins.nix.
    herdr-navigator = {
      url = "github:thanhdat77/herdr-navigator/v0.3.5";
      flake = false;
    };

    herdr-pluck = {
      url = "github:rmarganti/herdr-pluck/v0.3.1";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-claude-code = {
      url = "github:ryoppippi/nix-claude-code";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # herdr pins an old rust-overlay that still uses the deprecated stdenv.isLinux/isDarwin.
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-darwin,
      treefmt-nix,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-unstable = import nixpkgs-unstable { inherit system; };
      treefmtEval = treefmt-nix.lib.evalModule pkgs {
        imports = [ ./treefmt.nix ];
        _module.args.pkgs-unstable = pkgs-unstable;
      };

      hosts = {
        personal = {
          username = "shunta";
          email = "iamshunta@gmail.com";
          hostName = "personal";
          # TODO: Set to the personal GPG key ID once one is generated.
          signingKey = null;
          goPrivate = "github.com/5n7,github.com/mansion-friends";
        };
        work = {
          username = "s-komatsu";
          email = "s-komatsu@mercari.com";
          hostName = null;
          signingKey = "E534C891770B8015";
          goPrivate = "github.com/kouzoh";
        };
      };

      mkHost =
        name: hostAttrs:
        let
          host = hostAttrs // {
            profile = name;
          };
        in
        nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit
              host
              inputs
              system
              ;
          };
          modules = [
            ./hosts
            ./modules/darwin
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = {
                inherit
                  host
                  inputs
                  pkgs-unstable
                  ;
              };
              home-manager.users.${host.username} = import ./modules/home;
            }
          ];
        };
    in
    {
      darwinConfigurations = builtins.mapAttrs mkHost hosts;

      formatter.${system} = treefmtEval.config.build.wrapper;

      checks.${system}.formatting = treefmtEval.config.build.check self;
    };
}
