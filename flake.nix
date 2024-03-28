{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        name = "man-dskit";
        version = "0.1.0";
        nodejs = pkgs.nodejs_21;
      in {
        apps = {
          default = {
            type = "app";
            program = "${config.packages.serveStatic}/bin/${name}-server";
          };
        };

        devShells = {
          default = pkgs.mkShell {
            buildInputs = [pkgs.prefetch-npm-deps];
            inputsFrom = [self'.packages.default];
          };
        };

        packages = {
          default = pkgs.buildNpmPackage {
            inherit version nodejs;
            pname = name;
            src = ./.;
            npmDepsHash = "sha256-OK0AEVUn58LUygS2tqROBGdaW4gIRBiAA/ev+0PiLbg=";
            installPhase = ''
              cp --no-preserve=mode -r build $out
            '';
          };

          serveStatic = pkgs.writeShellApplication {
            name = "${name}-server";
            text = ''
              ${pkgs.httplz}/bin/httplz ${config.packages.default}
            '';
          };
        };
      };
    };
}
