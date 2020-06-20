{ callPackage, overrides ? {}, ... }:

{
  dav-4-tbsync = callPackage ./tbsync/dav-4.nix { };
} // overrides
