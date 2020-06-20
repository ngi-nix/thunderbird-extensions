{ stdenv, lib
, zip, unzip, thunderbird
, fetchurl, runCommand }:

let
  # There's no specific reason for having one, but it seems like if there were a global installation
  # directory, this would be it
  defaultExtensionDir = "lib/thunderbird/distribution/extensions";

  fetchMozillaAddon =
    { id, addon, version, sha256 }:
    fetchurl {
      # `*.xpi` is basically a zip file
      name = "${addon}.zip";
      url = "https://addons.thunderbird.net/user-media/addons/_attachments/${id}/${addon}-${version}-tb.xpi";
      inherit sha256;
    };
in {
  buildThunderbirdExtension =
    { pname, version, src
    , nativeBuildInputs ? []
    , emid, extensionDir ? defaultExtensionDir, topLevelPaths, ... }@args:
    stdenv.mkDerivation ((removeAttrs args [ "emid" "extensionDir" "topLevelPaths" ]) // {
      inherit emid extensionDir;

      nativeBuildInputs = [ zip unzip ] ++ nativeBuildInputs;

      buildPhase = ''
        runHook preBuild
        zip -rT $emid.xpi ${lib.concatStringsSep " " topLevelPaths}
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/$extensionDir/$emid
        cp $emid.xpi $out/$extensionDir
        runHook postInstall
      '';
    });

  buildMozillaExtension =
    { pname, version, postBuild ? ""
    , emid
    , id ? "", addon ? pname, sha256 ? lib.fakeSha256
    , xpi ? null, extensionDir ? defaultExtensionDir, ... }@args:
    runCommand "${pname}-${version}" {
      inherit emid extensionDir;
      src = if xpi != null
        then xpi
        else fetchMozillaAddon { inherit id addon version sha256; };
    } ''
      mkdir -p $out/$extensionDir
      cp $src $out/$extensionDir/$emid.xpi
      ${postBuild}
    '';
}
