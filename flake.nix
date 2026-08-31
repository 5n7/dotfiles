{
  description = "shunta's macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    herdr = {
      url = "github:herdrdev/herdr";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Plugin sources are pinned as non-flake inputs and built in modules/home/herdr.nix.
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

    hunk = {
      url = "github:modem-dev/hunk";
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
      hunk,
      nix-claude-code,
      nix-darwin,
      treefmt-nix,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      treefmtEval = treefmt-nix.lib.evalModule pkgs {
        imports = [ ./treefmt.nix ];
        _module.args.pkgs-unstable = import nixpkgs-unstable { inherit system; };
      };

      # Per-host identity: everything that differs between profiles lives here and
      # is passed through as a single `host` record.
      hosts = {
        personal = {
          username = "shunta";
          email = "iamshunta@gmail.com";
          hostName = "personal";
          # signingKey stays null; TODO: set to personal GPG key ID after generation
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
          inherit system;
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
              home-manager.sharedModules = [ inputs.hunk.homeManagerModules.default ];
              home-manager.extraSpecialArgs = {
                pkgs-unstable = import nixpkgs-unstable { inherit system; };
                inherit
                  host
                  inputs
                  system
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
