with (import <nixpkgs> {});
mkShell {
  buildInputs = [
    gleam
  ];
}
