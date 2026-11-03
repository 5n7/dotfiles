{ bun, runCommand }:
runCommand "herdr-app-pluck"
  {
    nativeBuildInputs = [ bun ];
    meta.mainProgram = "pluck";
  }
  ''
    cd ${./src}
    bun test
    bun build --compile --target=bun main.ts --outfile $out/bin/pluck
    # macOS kills an executable whose signature fails, as Bun 1.3's did, before
    # it can print its usage and exit 64.
    $out/bin/pluck || [ $? -eq 64 ]
  ''
