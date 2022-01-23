# Notes:
# You'll want the direnv plugin in VSCode.
# If rust-analyzer fails to load in VSCode, try restarting the rust-analyzer server.
# the VSCode direnv plugin is a little racey. And it can load after the rust-analyzer starts.
{
  description = "A very basic flake";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/release-21.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        pkgsCross = import nixpkgs
          {
            inherit system overlays;
            crossSystem = pkgs.lib.systems.examples.x86_64-darwin // {
              rustc.config = "x86_64-apple-darwin";
            };
          };
        rustStable = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" ];
        };
      in
      {
        defaultPackage = pkgs.rustPlatform.buildRustPackage rec {
          pname = "slip39";
          version = "0.1.1";
          # target = "";

          nativeBuildInputs = [ rustStable ] ++ (with pkgs.darwin.apple_sdk.frameworks; [ Security ]);

          src = ./.;

          cargoLock = {
            lockFile = ./Cargo.lock;
            outputHashes = {
              "sssmc39-0.0.3" = "sha256-nMASTns/pQ47L4YYTZeDjl1Kr7iiEFqMZLckJuLzi28=";
            };
          };

          meta = with pkgs.lib; {
            description = "SLIP-0039 compatible secret sharing tool";
            homepage = "https://github.com/Internet-of-People/slip39-rust";
            license = licenses.gpl3;
            maintainers = [ maintainers.tailhook ];
          };
        };
        devShell = pkgs.mkShell {
          buildInputs = [
            rustStable
            # If the project requires openssl, uncomment these
            # pkgs.pkg-config
            # pkgs.openssl
          ] ++ (if system == "aarch64-darwin" then (with pkgs.darwin.apple_sdk.frameworks; [ Security ]) else [ ]);
          # If the project requires openssl, uncomment this
          # PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
        };
        # crossPkg = pkgs.pkgsCross.x86_64-darwin.rustPlatform.buildRustPackage rec {
        crossPkg = pkgsCross.rustPlatform.buildRustPackage rec {
          pname = "slip39";
          version = "0.1.1";

          nativeBuildInputs = [ rustStable ];

          src = ./.;

          cargoLock = {
            lockFile = ./Cargo.lock;
            outputHashes = {
              "sssmc39-0.0.3" = "sha256-nMASTns/pQ47L4YYTZeDjl1Kr7iiEFqMZLckJuLzi28=";
            };
          };

          meta = with pkgs.lib; {
            description = "SLIP-0039 compatible secret sharing tool";
            homepage = "https://github.com/Internet-of-People/slip39-rust";
            license = licenses.gpl3;
            maintainers = [ maintainers.tailhook ];
          };
        };

      }
    );
}
