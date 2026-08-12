{
  pi-coding-agent,
  lib,

  curl,
  fd,
  jq,
  ripgrep,
  wget,

  cargo,
  ruff,

  forgejo-cli,
  gh,
  glab,
  tea,
}:

let
  env_PATH = lib.makeBinPath ([
    # general-purpose tools
    curl
    fd
    jq
    ripgrep
    wget

    # programming related tools
    cargo
    ruff

    # git forge
    forgejo-cli
    gh
    glab
    tea
  ]);

  upstreamPostFixup = ''
    wrapProgram $out/bin/pi --prefix PATH : ${
      lib.makeBinPath [
        ripgrep
        fd
      ]
    } \
      --set-default PI_SKIP_VERSION_CHECK 1 \
      --set-default PI_TELEMETRY 0
  '';
in

assert pi-coding-agent.postFixup == upstreamPostFixup;

(pi-coding-agent.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [ ./pi-coding-agent.patch ];
  postFixup = "wrapProgram $out/bin/pi --prefix PATH : ${env_PATH}";
}))
