{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.services.thunderbird;
in
{
  options.services.thunderbird = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to include Thunderbird into the system configuration.
      '';
    };

    extensions = mkOption {
      type = with types; oneOf [ str path package ];
      default = [ ];
      description = ''
        Extensions to install into the profile by default.
      '';
    };

    policyConfig =
      let
        baseTypes = with types; (oneOf [
          int
          bool
          str
          (listOf (oneOf baseTypes))
          (attrsOf baseTypes)
        ]) // { description = "Valid types for policy values"; };

        topLevel = with types; attrsOf (baseTypes // {
          description = ''
            Recursive type of the policy configuration, allowing any of the
            baseTypes.
          '';
        });
      in
      mkOption {
        type = topLevel;
        default = { };
        description = ''
          Mozilla policy configuration for Thunderbird.
        '';
      };
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      let
        thunderbird-with-extensions = pkgs.thunderbird-with-extensions.override {
          thunderbirdExtensions = cfg.extensions;
          policyConfig = cfg.policyConfig;
        };
      in
      [ thunderbird-with-extensions ];
  };
}
