{ stdenv, fetchFromGitHub, zip, unzip }:

stdenv.mkDerivation rec {
  pname = "dav-4-tbsync";
  version = "1.12";

  src = fetchFromGitHub {
    owner = "jobisoft";
    repo = "DAV-4-TbSync";
    rev = "v${version}";
    sha256 = "08g0nidrcfh0hk2kx8dcx0q2vifhrr1fk23cinpaf89159216c38";
  };

  nativeBuildInputs = [ zip unzip ];

  EXTENSION_DIR = "lib/thunderbird/distribution/extensions";
  EMID = "dav4tbsync@jobisoft.de";

  # This should be a copy and paste build command
  # https://github.com/jobisoft/DAV-4-TbSync/blob/master/Makefile.bat#L9
  buildPhase = ''
    runHook preBuild
    zip -rT $EMID.xpi content _locales skin chrome.manifest manifest.json bootstrap.js LICENSE CONTRIBUTORS.md
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/$EXTENSION_DIR/$EMID
    cp $EMID.xpi $out/$EXTENSION_DIR
    runHook postInstall
  '';
}
