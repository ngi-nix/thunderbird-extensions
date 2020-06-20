{ thunderbird-utils, fetchFromGitHub }:

thunderbird-utils.buildThunderbirdExtension rec {
  pname = "eas-4-tbsync";
  version = "1.14";

  src = fetchFromGitHub {
    owner = "jobisoft";
    repo = "EAS-4-TbSync";
    rev = "v${version}";
    sha256 = "05rwm63inx0adbl9cy3gfia2grdpf9kmm8jchn85plkgbfjr70g9";
  };

  emid = "eas4tbsync@jobisoft.de";
  # This should be a copy and paste of the paths in the zip command here
  # https://github.com/jobisoft/EAS-4-TbSync/blob/master/Makefile.bat#L9
  topLevelPaths = [
    "content" "_locales" "skin" "chrome.manifest" "manifest.json" "CONTRIBUTORS.md" "LICENSE"
    "README.md" "bootstrap.js"
  ];
}
