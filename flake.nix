{
  description = "Flake for a Thunderbird with extensions";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs = { type = "github"; owner = "NixOS"; repo = "nixpkgs"; ref = "nixos-20.03"; };

  # Upstream source tree(s).
  inputs.tbsync-src = { type = "github"; owner = "jobisoft"; repo = "TbSync"; ref = "master"; flake = false; };

  outputs = { self, nixpkgs, tbsync-src, ... }@inputs:
    let
      # System types to support.
      supportedSystems = [ "x86_64-linux" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

      # Generate a user-friendly version numer.
      version = builtins.substring 0 8 tbsync-src.lastModifiedDate;

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
              inherit version;
              src = tbsync-src;
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
            tbsync dav-4-tbsync eas-4-tbsync;

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
          with import (nixpkgs + "/nixos/lib/testing-python.nix") {
            inherit system;
          };
          with self.packages.${system};

          makeTest {
            nodes = {
              machine = { ... }: {
                environment.systemPackages = [ thunderbird ];
              };
            };

            testScript =
              ''
                import time

                start_all()

                machine.execute("mkdir -p ~/fakeprofile")
                machine.execute("thunderbird --headless --profile ~/fakeprofile &")
                time.sleep(128)

                if "${tbsync.emid}" in machine.succeed("ls ~/fakeprofile/extensions"):
                    raise Exception("Unknown extension in profile")

                if not "1" in machine.succeed("ls ~/fakeprofile/extensions | wc -l"):
                    raise Exception("Invalid number of extensions")

                machine.shutdown()
              '';
          };

        thunderbird-tbsync =
          with import (nixpkgs + "/nixos/lib/testing-python.nix") {
            inherit system;
          };
          with self.packages.${system};

          makeTest {
            nodes = {
              machine = { ... }: {
                imports = [ self.nixosModules.thunderbird ];
                services.thunderbird = {
                  enable = true;
                  extensions = [ tbsync ];
                };
              };
            };

            testScript =
              ''
                import time

                start_all()

                machine.execute("mkdir -p ~/fakeprofile")
                machine.execute("thunderbird --headless --profile ~/fakeprofile &")
                time.sleep(128)

                if not "${tbsync.emid}" in machine.succeed("ls ~/fakeprofile/extensions"):
                    raise Exception("Failed to automatically download extension")

                if not "2" in machine.succeed("ls ~/fakeprofile/extensions | wc -l"):
                    raise Exception("Invalid number of extensions")

                machine.shutdown()
              '';
          };
      });

    };
}
