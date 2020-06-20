{ thunderbird-utils, fetchFromGitHub }:

thunderbird-utils.buildThunderbirdExtension rec {
  pname = "dav-4-tbsync";
  version = "1.12";

  src = fetchFromGitHub {
    owner = "jobisoft";
    repo = "DAV-4-TbSync";
    rev = "v${version}";
    sha256 = "08g0nidrcfh0hk2kx8dcx0q2vifhrr1fk23cinpaf89159216c38";
  };

  emid = "dav4tbsync@jobisoft.de";
  # This should be a copy and paste of the paths in the zip command here
  # https://github.com/jobisoft/DAV-4-TbSync/blob/master/Makefile.bat#L9
  topLevelPaths = [
    "content" "_locales" "skin" "chrome.manifest" "manifest.json" "bootstrap.js" "LICENSE"
    "CONTRIBUTORS.md"
  ];
}
