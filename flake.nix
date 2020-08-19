{
  description = "Flake for a Thunderbird with extensions";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs = { type = "github"; owner = "NixOS"; repo = "nixpkgs"; ref = "nixos-20.03"; };

  # Upstream source tree(s).
  inputs.tbsync-src = { type = "github"; owner = "jobisoft"; repo = "TbSync"; ref = "master"; flake = false; };
  inputs.autocrypt-src = { type = "github"; owner = "autocrypt-thunderbird"; repo = "autocrypt-thunderbird"; ref = "master"; flake = false; };

  outputs = { self, nixpkgs, tbsync-src, autocrypt-src, ... }@inputs:
    let
      # System types to support.
      supportedSystems = [ "x86_64-linux" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

      # Generate a user-friendly version numer.
      tbsync-version = builtins.substring 0 8 tbsync-src.lastModifiedDate;
      autocrypt-version = builtins.substring 0 8 autocrypt-src.lastModifiedDate;
      version = tbsync-version;

    in
    {

      # A Nixpkgs overlay.
      overlay = final: prev: with final.pkgs; {

        thunderbird-utils = recurseIntoAttrs (callPackage ./pkgs/thunderbird-extensions/thunderbird-utils.nix { });

        thunderbird-with-extensions = callPackage ./pkgs/thunderbird/with-extensions.nix { };

        thunderbird-extensions = recurseIntoAttrs (callPackage ./pkgs/thunderbird-extensions {
          overrides = {
            # not really ideal but passes the values to the derivation
            tbsync = callPackage ./pkgs/thunderbird-extensions/tbsync { } {
              version = tbsync-version;
              src = tbsync-src;
            };

            autocrypt = callPackage ./pkgs/thunderbird-extensions/autocrypt { } {
              version = autocrypt-version;
              src = autocrypt-src;
            };
          };
        });

      };

      # Provide some binary packages for selected system types.
      packages = forAllSystems (system:
        let
          pkgSet = nixpkgsFor.${system};
        in
        {

          inherit (pkgSet)
            thunderbird thunderbird-with-extensions;

          inherit (pkgSet.thunderbird-extensions)
            enigmail
            tbsync dav-4-tbsync eas-4-tbsync
            autocrypt;

          sample-thunderbird = pkgSet.thunderbird-with-extensions.override {
            thunderbirdExtensions = with pkgSet.thunderbird-extensions; [
              enigmail

              tbsync
              dav-4-tbsync
              eas-4-tbsync
            ];
          };

        });

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      defaultPackage = forAllSystems (system: self.packages.${system}.thunderbird-with-extensions);

      # A NixOS module, if applicable (e.g. if the package provides a system service).
      nixosModules.thunderbird =
        { pkgs, ... }:
        {
          imports =
            [
              ./modules/thunderbird.nix
            ];

          nixpkgs.overlays = [ self.overlay ];
        };

      # Tests run by 'nix flake check' and by Hydra.
      checks = forAllSystems (system: {
        inherit (self.packages.${system})
          thunderbird thunderbird-with-extensions
          enigmail tbsync dav-4-tbsync eas-4-tbsync
          sample-thunderbird;

        # Additional tests, if applicable.
        thunderbird-default =
          with nixpkgsFor.${system};
          with self.packages.${system};
          stdenv.mkDerivation {
            name = "thunderbird-default-test";
            unpackPhase = ":";
            buildInputs = [ thunderbird ];
            buildPhase = ''
              export HOME=$(pwd)
              mkdir -p $HOME/fakeprofile
              thunderbird --headless --profile $HOME/fakeprofile &
              sleep 128
              ls $HOME/fakeprofile/extensions | grep -q ${tbsync.emid} && exit 1 || echo "valid extensions"
              [ "$(ls $HOME/fakeprofile/extensions | wc -l)" = "1" ] && echo "valid number of extensions" || exit 1
            '';
            installPhase = ''
              mkdir -p $out
            '';
          };

        thunderbird-tbsync =
          with nixpkgsFor.${system};
          with self.packages.${system};
          stdenv.mkDerivation {
            name = "thunderbird-tbsync-test";
            unpackPhase = ":";
            buildInputs = [
              (thunderbird-with-extensions.override {
                thunderbirdExtensions = [ thunderbird-extensions.tbsync ];
              })
            ];
            buildPhase = ''
              export HOME=$(pwd)
              mkdir -p $HOME/fakeprofile
              thunderbird --headless --profile $HOME/fakeprofile &
              sleep 128
              ls $HOME/fakeprofile/extensions | grep -q ${tbsync.emid} && echo "found tbsync" || exit 1
              [ "$(ls $HOME/fakeprofile/extensions | wc -l)" = "2" ] && echo "valid number of extensions" || exit 1
            '';
            installPhase = ''
              mkdir -p $out
            '';
          };
      });

    };
}
