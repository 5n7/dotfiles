{ bun, runCommand }:
runCommand "herdr-app-pick"
  {
    nativeBuildInputs = [ bun ];
    meta.mainProgram = "pick";
  }
  ''
    cd ${./src}
    bun test
    bun build --compile --target=bun main.ts --outfile $out/bin/pick
    # macOS kills an executable whose signature fails, as Bun 1.3's did, before
    # it can print its usage and exit 64.
    $out/bin/pick || [ $? -eq 64 ]
  ''
