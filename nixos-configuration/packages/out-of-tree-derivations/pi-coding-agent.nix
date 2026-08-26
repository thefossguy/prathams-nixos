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
  postPatch = ''
    ${oldAttrs.postPatch or ""}

    substituteInPlace packages/coding-agent/src/modes/interactive/interactive-mode.ts \
      --replace-fail "// Main interactive loop" "await this.handleOpenExternalEditor();

                // Main interactive loop"

    substituteInPlace packages/coding-agent/src/modes/interactive/interactive-mode.ts \
      --replace-fail "this.settingsManager.setLastChangelogVersion(VERSION);" ""

    substituteInPlace packages/coding-agent/src/core/system-prompt.ts \
      --replace-fail \
      "{guidelines}

    Pi documentation (read only when the user asks about pi itself, its SDK, extensions, themes, skills, or TUI):
    - Main documentation: \''${readmePath}
    - Additional docs: \''${docsPath}
    - Examples: \''${examplesPath} (extensions, custom tools, SDK)
    - When reading pi docs or examples, resolve docs/... under Additional docs and examples/... under Examples, not the current working directory
    - When asked about: extensions (docs/extensions.md, examples/extensions/), themes (docs/themes.md), skills (docs/skills.md), prompt templates (docs/prompt-templates.md), TUI components (docs/tui.md), keybindings (docs/keybindings.md), SDK integrations (docs/sdk.md), custom providers (docs/custom-provider.md), adding models (docs/models.md), pi packages (docs/packages.md), environment variables (docs/environment-variables.md)
    - When working on pi topics, read the docs and examples, and follow .md cross-references before implementing
    - Always read pi .md files completely and follow links to related docs (e.g., tui.md for TUI API details)\`;" \
      "{guidelines}\`;"
  '';

  postFixup = ''
    wrapProgram $out/bin/pi \
        --prefix PATH : ${env_PATH} \
        --set NVIM_LOG_FILE /dev/null \
        --set PI_CODING_AGENT_DIR '~/.config/pi/agent' \
        #EOF
  '';
}))
