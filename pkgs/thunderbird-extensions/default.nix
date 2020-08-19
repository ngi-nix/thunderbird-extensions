{ callPackage, thunderbird-utils, overrides ? { }, ... }:

{
  enigmail = thunderbird-utils.buildMozillaExtension {
    pname = "enigmail";
    version = "2.1.6";

    id = "71";
    # https://gitlab.com/enigmail/enigmail/-/blob/ac782ab01c9a73e64b016e30849c2be75ea74e51/uuid_enig.txt#L15
    emid = "{847b3a00-7ab1-11d4-8f02-006008948af5}";
    sha256 = "1bd0yslh8k2j5rp7f796yq1kigpbx0alyfs5gml4z01aa6m24wb9";
  };

  dav-4-tbsync = callPackage ./tbsync/dav-4.nix { };
  eas-4-tbsync = callPackage ./tbsync/eas-4.nix { };
} // overrides
