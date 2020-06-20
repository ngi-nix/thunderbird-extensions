{ thunderbird-utils }:
{ version, src }:

thunderbird-utils.buildThunderbirdExtension {
  pname = "tbsync";
  inherit version src;

  emid = "tbsync@jobisoft.de";
  # This should be a copy and paste of the paths in the zip command here
  # https://github.com/jobisoft/TbSync/blob/master/Makefile.bat#L9
  topLevelPaths =
    [
      "content" "_locales" "skin" "chrome.manifest" "manifest.json" "LICENSE" "README.md"
      "bootstrap.js" "CONTRIBUTORS.md"
    ];
}
