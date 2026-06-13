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
in

(pi-coding-agent.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [ ./pi-coding-agent.patch ];
  postInstall = ''
    ${oldAttrs.postInstall or ""}

    wrapProgram $out/bin/pi \
        --prefix PATH : ${env_PATH} \
        --set PI_CODING_AGENT_DIR '~/.config/pi/agent' \
        --set PI_OFFLINE 1 \
        --set PI_SKIP_VERSION_CHECK 1 \
        --set PI_TELEMETRY 0 \
        --add-flags "--offline" \
        #EOF
  '';
}))
