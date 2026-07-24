{
  description = "Personal dotfiles tool profile";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-node25.url = "github:NixOS/nixpkgs/d233902339c02a9c334e7e593de68855ad26c4cb";
    ccusage.url = "github:ryoppippi/ccusage";
  };

  outputs = { self, nixpkgs, nixpkgs-node25, ccusage }:
    let
      supportedSystems = [
        "x86_64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          nodePkgs = nixpkgs-node25.legacyPackages.${system};
        in {
          default = pkgs.buildEnv {
            name = "dotfiles-profile";
            paths = [
              ccusage.packages.${system}.ccusage
              pkgs.codex
              pkgs.ffmpeg
              pkgs.gcc
              pkgs.gh
              pkgs.gnumake
              pkgs.go
              pkgs.go-tools
              pkgs.godot_4
              pkgs.gopls
              pkgs.neovim
              nodePkgs.nodejs_25
              pkgs.stow
              pkgs.tmux
              pkgs.tree-sitter
              pkgs.unison
              pkgs.yt-dlp
            ];
          };
        });
    };
}
