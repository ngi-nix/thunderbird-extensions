{ stdenv, fetchFromGitHub, zip, unzip }:

stdenv.mkDerivation rec {
  pname = "eas-4-tbsync";
  version = "1.14";

  src = fetchFromGitHub {
    owner = "jobisoft";
    repo = "EAS-4-TbSync";
    rev = "v${version}";
    sha256 = "05rwm63inx0adbl9cy3gfia2grdpf9kmm8jchn85plkgbfjr70g9";
  };

  nativeBuildInputs = [ zip unzip ];

  EXTENSION_DIR = "lib/thunderbird/distribution/extensions";
  EMID = "eas4tbsync@jobisoft.de";

  # This should be a copy and paste build command
  # https://github.com/jobisoft/EAS-4-TbSync/blob/master/Makefile.bat#L9
  buildPhase = ''
    runHook preBuild
    zip -rT $EMID.xpi content _locales skin chrome.manifest manifest.json CONTRIBUTORS.md LICENSE README.md bootstrap.js
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/$EXTENSION_DIR/$EMID
    cp $EMID.xpi $out/$EXTENSION_DIR
    runHook postInstall
  '';
}
