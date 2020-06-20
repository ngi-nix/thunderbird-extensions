{ lib, writeText, runCommand, thunderbird
, zip, unzip
, thunderbirdExtensions ? []
, policyConfig ? {} }:

let
  distributionDir = "lib/thunderbird/distribution";
  policyFilename = "policies.json";

  extensionPolicy = writeText "policies.json" (builtins.toJSON {
    policies = {
      # Disable updates because it's managed through Nix so it won't work anyway
      DisableAppUpdate = true;
      # The only actual setting from Extensions we care about
      Extensions.Install = map (ext: "/${ext}/${ext.extensionDir}/${ext.emid}.xpi") thunderbirdExtensions;
    };
  });

  defaultPolicy = if builtins.pathExists "${thunderbird}/${distributionDir}/${policyFilename}"
    then builtins.fromJSON (builtins.readFile "${thunderbird}/${distributionDir}/${policyFilename}")
    else {};

  policy = with lib; recursiveUpdate (recursiveUpdate defaultPolicy extensionPolicy) policyConfig;
in runCommand "thunderbird-with-extensions-${thunderbird.version}" {
  dontStrip = true;
  dontPatchELF = true;
  meta = thunderbird.meta // {
    platforms = lib.platforms.linux;
  };

  nativeBuildInputs = [ zip unzip ];
} ''
  mkdir -p $out

  # Fixup omni.ja to lookup the policies.json at ${distributionDir}/${policyFilename}
  mkdir -p $out/lib/thunderbird
  # https://developer.mozilla.org/en-US/docs/Mozilla/About_omni.ja_(formerly_omni.jar)
  mkdir -p $TMPDIR/omni
  unzip -d $TMPDIR/omni ${thunderbird}/lib/thunderbird/omni.ja
  sed -i "s@\"/etc/\".*@\"$out/${distributionDir}\"@" $TMPDIR/omni/components/EnterprisePolicies.js
  (cd $TMPDIR/omni && zip -qr9XD $out/lib/thunderbird/omni.ja *)

  # Copy over the policy
  mkdir -p $out/${distributionDir}
  cp ${extensionPolicy} $out/${distributionDir}/${policyFilename}

  # Copy over Thunderbird
  cp -nr ${thunderbird}/* $out

  # Fix reference in thunderbird executable
  chmod 755 $out/bin
  sed -i "s@${thunderbird}@$out@g" $out/bin/thunderbird
''
