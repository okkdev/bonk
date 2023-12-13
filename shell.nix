with (import <nixpkgs> {});
let
 gleam = stdenv.mkDerivation rec {
    name = "gleam-${version}";
    version = "0.22.1";
    src = fetchurl {
      url = "https://github.com/gleam-lang/gleam/releases/download/v${version}/gleam-v${version}-macos-arm64.tar.gz";
      sha256 = "sha256-r2JiBq5eC38nKwbyWzVycwdiELoDRj+fjy1lSv4N2AM=";
    };
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      tar -xf $src -C $out/bin
    '';
  };
in
mkShell {
  buildInputs = [
    gleam
    rebar3
    flyctl
  ];
}
