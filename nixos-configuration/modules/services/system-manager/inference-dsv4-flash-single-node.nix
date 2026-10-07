{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.inferenceDSv4FlashSingleNode;
  servicePortInt = 8080;
  servicePortStr = builtins.toString servicePortInt;
  contextSize = 1024 * 512;
in
{
  systemd = {
    sockets = {
      "${serviceConfig.unitName}-base" = {
        enable = true;
        wantedBy = [ "sockets.target" ];
        listenStreams = [ "0.0.0.0:${servicePortStr}" ];
      };
    };

    services = {
      "${serviceConfig.unitName}-proxy" = {
        enable = true;
        requires = [ "${serviceConfig.unitName}-base.service" ];
        after = [ "${serviceConfig.unitName}-base.service" ];

        unitConfig.JoinsNamespaceOf = [ "${serviceConfig.unitName}-base.service" ];

        serviceConfig = {
          ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd 0.0.0.0:${servicePortStr}";
          DynamicUser = true;
          RestrictAddressFamilies = "AF_NET";
          PrivateNetwork = true;
        };
      };

      "${serviceConfig.unitName}-base" = {
        enable = true;
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          SyslogIdentifier = "%n";
          DynamicUser = true;
          Type = "exec";
          ExecStart = builtins.concatStringSep " " [
            (lib.getExe' pkgs.llama-cpp "llama-server")

            # llama.cpp itself
            "--offline"
            "--host 0.0.0.0"
            "--port ${servicePortStr}"
            "--no-log-timestamps"

            # base model
            "--alias DeepSeek-V4-Flash-0731"
            "--model ${pkgs.fetched_DeepSeek-V4-Flash-0731-GGUF-UD-IQ3_XXS}/UD-IQ3_XXS/DeepSeek-V4-Flash-0731-UD-IQ3_XXS-00001-of-00004.gguf"
            "--flash-attn on"
            "--temperature 1.0"
            "--top-p 0.95"
            "--ctx-size ${builtins.toString contextSize}"
            "--n-gpu-layers all"
            "--fit off"

            # speculative decoding
            "--spec-draft-model ${pkgs.fetched_DeepSeek-V4-Flash-0731-GGUF-UD-IQ3_XXS}/dspark-DeepSeek-V4-Flash-0731-Q8_0.gguf"
            "--spec-type draft-dspark"
            "--spec-draft-n-max 3"
            "--n-gpu-layers-draft all"
          ];
          ExecStartPost = "${lib.getExe pkgs.bash} -c 'until (: >/dev/tcp/0.0.0.0/${servicePortStr}) 2>/dev/null; do sleep 1; done'";
          Restart = "on-failure";
          RestartSec = "5s";

          # filesystem hardening
          LimitCORE = "0";
          ProtectHome = "tmpfs";
          BindReadOnlyPaths = pkgs.fetched_DeepSeek-V4-Flash-0731-GGUF-UD-IQ3_XXS;
          PrivateDevices = true;
          NoExecPaths = [ "/" ];
          ExecPaths = [ "/nix/store" ];

          # networking hardening
          PrivateNetwork = true;
          RestrictAddressFamilies = "AF_NET";

          # process, IPC, kernel hardening
          ProtectProc = "invisible";
          ProcSubset = "pid";
          PrivateIPC = true;
          ProtectHostname = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectKernelLogs = true;
          ProtectControlGroups = true;
          RestrictNamespaces = true;
          RestrictRealtime = true;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = [
            "@system-service"
            "~@privileged io_uring_setup"
          ];
          SystemCallErrorNumber = "EPERM";

          TasksMax = 4096;
        }
        // lib.attrsets.optionalAttrs (builtins.elem "nvidia" config.customOptions.gpuSupport) {
          PrivateDevices = false;
          DevlicePolicy = "closed";
          DeviceAllow = builtins.map (devNode: "${devNode} rw") [
            "/dev/nvidia-uvm"
            "/dev/nvidia-uvm-tools"
            "/dev/nvidia0"
            "/dev/nvidiactl"
          ];
          SupplementaryGroups = [ "video" ];
        }
        // lib.attrsets.optionalAttrs (!(builtins.elem "nvidia" config.customOptions.gpuSupport)) {
          ProcSubset = "pid";
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ servicePortInt ];
}
