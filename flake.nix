{
  description = "Antsy Alien Attack Pico";
  inputs.nixpkgs.url = "nixpkgs/nixos-23.05";
  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.default =
      with nixpkgs.legacyPackages.x86_64-linux;

      stdenv.mkDerivation rec {
        name = "antsy-alien-attack-pico";
        version = "1.23.15723";

        src = pkgs.fetchzip {
          url = "https://github.com/wimpysworld/antsy-alien-attack-pico/releases/download/${version}/antsy-alien-attack-pico_linux.zip";
          sha256 = "sha256-S/F99LsB83cqn3mQIEEw0zxFrDt64zrKiXSrgtsC8zA=";
        };

        buildInputs = [ makeWrapper ];

        installPhase = ''
            prog=$out/libexec/antsy-alien-attack-pico
            mkdir -p $out/bin $(dirname $prog)

            cp ./antsy-alien-attack-pico $prog
            chmod +w $prog

            patchelf \
              --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
              $prog

            makeWrapper $prog $out/bin/antsy-alien-attack-pico \
              --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ SDL2 ]}

            cp ./data.pod $(dirname $prog)/data.pod
        '';

          meta = with lib; {
            homepage = "https://wimpress.itch.io/antsy-alien-attack-pico";
            description = "A juicy retro-style vertically scrolling shoot 'em up";
            platforms = platforms.linux;
        };
      };
  };
}
