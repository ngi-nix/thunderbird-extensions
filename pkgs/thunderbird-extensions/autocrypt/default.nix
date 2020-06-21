{ thunderbird-utils, python, perl }:
{ version, src }:

thunderbird-utils.buildThunderbirdExtension {
  pname = "autocrypt";
  inherit version src;

  # https://github.com/autocrypt-thunderbird/autocrypt-thunderbird/blob/3953dda07ad8b0d99beab1c9e61da147bcaf3ff5/package/app.jsm#L21
  emid = "{c0b84c00-227f-4762-b4fc-354bcfe0f865}";
  nativeBuildInputs = [ python perl ];
  buildPhase = ''
    ./configure
    make xpi
    mv build/autocrypt*.xpi $emid.xpi
  '';
}
