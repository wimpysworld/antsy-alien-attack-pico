{
  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.default =
      with nixpkgs.legacyPackages.x86_64-linux;

      stdenv.mkDerivation {
        name = "antsy-alien-attack-pico";

        buildInputs = [ makeWrapper ];

        unpackPhase = "true";

        installPhase =
          ''
            prog=$out/libexec/antsy-alien-attack-pico/antsy-alien-attack-pico
            mkdir -p $out/bin $(dirname $prog)
            cp ${./antsy-alien-attack-pico} $prog
            chmod +w $prog

            patchelf \
              --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
              $prog

            makeWrapper $prog $out/bin/antsy-alien-attack-pico \
              --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ SDL2 ]}

            cp ${./data.pod} $(dirname $prog)/data.pod
          '';
      };

  };
}
