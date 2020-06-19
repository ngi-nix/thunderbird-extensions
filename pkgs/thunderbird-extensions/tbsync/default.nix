{ stdenv, zip, unzip }:
{ version, src }:

stdenv.mkDerivation {
  pname = "tbsync";
  inherit version src;

  nativeBuildInputs = [ zip unzip ];

  EXTENSION_DIR = "lib/thunderbird/distribution/extensions";
  EMID = "tbsync@jobisoft.de";

  # This should be a copy and paste build command
  # https://github.com/jobisoft/TbSync/blob/master/Makefile.bat#L9
  buildPhase = ''
    runHook preBuild
    zip -rT $EMID.xpi content _locales skin chrome.manifest manifest.json LICENSE README.md bootstrap.js CONTRIBUTORS.md
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/$EXTENSION_DIR/$EMID
    cp $EMID.xpi $out/$EXTENSION_DIR
    runHook postInstall
  '';
}
