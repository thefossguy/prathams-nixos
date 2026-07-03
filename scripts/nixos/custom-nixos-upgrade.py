#!/usr/bin/env python3

import json
import logging
import os
import shutil
import subprocess
import sys
import time


nixos_machine_hostname = os.environ.get("NIXOS_MACHINE_HOSTNAME", None)
nixos_config_repo_path = "/etc/nixos"
nixos_config_repo_url = "https://gitlab.com/thefossguy/prathams-nixos.git"


def re_clone_nixos_config_repo() -> None:
    git_clone_process = subprocess.run(
        [
            "git",
            "clone",
            nixos_config_repo_url,
            nixos_config_repo_path,
        ],
        check=False,
        capture_output=True,
        text=True,
    )
    if git_clone_process.returncode != 0:
        logging.error(
            f"Could not clone `{nixos_config_repo_url}` at `{nixos_config_repo_path}`\n{git_clone_process.stderr.strip()}",
        )
        sys.exit(1)


def ensure_nixos_config_repo_integrity() -> None:
    git_status_process = subprocess.run(
        [
            "git",
            "-C",
            nixos_config_repo_path,
            "status",
        ],
        check=False,
        capture_output=True,
        text=True,
    )
    if git_status_process.returncode != 0:
        logging.warning(
            f"The NixOS configuration repository's (`{nixos_config_repo_path}`) status was not okay\n{git_status_process.stderr.strip()}",
        )
        try:
            shutil.rmtree(nixos_config_repo_path)
        except (FileNotFoundError, NotADirectoryError):
            raise
        except Exception:
            pass
        re_clone_nixos_config_repo()


def pull_nixos_config_changes() -> None:
    git_pull_process = subprocess.run(
        [
            "git",
            "-C",
            nixos_config_repo_path,
            "pull",
            "--no-rebase",
        ],
        check=False,
        capture_output=True,
        text=True,
    )
    if git_pull_process.returncode != 0:
        logging.warning(
            f"Could not pull changes for NixOS configuration repository (`{nixos_config_repo_path}`)\n{git_pull_process.stderr.strip()}",
        )
        try:
            shutil.rmtree(nixos_config_repo_path)
        except (FileNotFoundError, NotADirectoryError):
            raise
        except Exception:
            pass
        re_clone_nixos_config_repo()


def pre_start_checks() -> None:
    error_out = False

    if os.getuid() != 0:
        logging.error("The script must run as `root`")
        error_out = True

    if not nixos_machine_hostname:
        logging.error("$NIXOS_MACHINE_HOSTNAME is empty")
        error_out = True

    if error_out:
        sys.exit(1)

    ensure_nixos_config_repo_integrity()
    pull_nixos_config_changes()


def update_lockfile() -> None:
    current_time = time.time()
    flake_lockfile_delta = current_time - os.path.getmtime(
        f"{nixos_config_repo_path}/flake.lock",
    )
    flake_file_delta = current_time - os.path.getmtime(
        f"{nixos_config_repo_path}/flake.nix",
    )
    if flake_lockfile_delta > 55 or flake_file_delta < 120:
        nix_flake_update_process = subprocess.run(
            [
                "nix",
                "flake",
                "update",
                "--flake",
                nixos_config_repo_path,
            ],
            check=False,
            capture_output=True,
            text=True,
        )
        if nix_flake_update_process.returncode != 0:
            logging.warning(f"Could not update the lockfile\n{nix_flake_update_process.stderr.strip()}")
    else:
        logging.info("Not updating flake.lock to be under GitHub's free rate limit.")


def get_flake_store_path() -> str:
    update_lockfile()
    nix_flake_archive_process = subprocess.run(
        ["nix", "flake", "archive", "--no-pretty", "--json", nixos_config_repo_path],
        check=False,
        text=True,
        capture_output=True,
    )
    if nix_flake_archive_process.stdout:
        flake_store_path = json.loads(nix_flake_archive_process.stdout).get("path")
    if not flake_store_path:
        logging.error(
            f"Could not determine the flake store path of `{nixos_config_repo_path}`\n{nix_flake_archive_process.stderr.strip()}",
        )
        sys.exit(1)
    else:
        return flake_store_path


def evaluate_latest_nixos_generation_outpath(
    flake_store_path: str,
) -> str:
    nix_eval_process = subprocess.run(
        [
            "nix-instantiate",
            "--eval",
            "--raw",
            "--expr",
            f'(builtins.getFlake "{flake_store_path}").outputs.nixosConfigurations.{nixos_machine_hostname}.config.system.build.toplevel.outPath',
        ],
        check=False,
        text=True,
        capture_output=True,
    )
    if nix_eval_process.returncode != 0:
        logging.error(
            f"Could not determine the derivation path for `{nixos_machine_hostname}`'s NixOS configuration\n{nix_eval_process.stderr.strip()}",
        )
        sys.exit(1)
    else:
        return nix_eval_process.stdout.strip()


def main() -> None:
    logging.basicConfig(level=logging.INFO)
    pre_start_checks()

    flake_store_path = get_flake_store_path()
    logging.info(f"Flake store path: '{flake_store_path}'")

    latest_nixos_generation_outpath = evaluate_latest_nixos_generation_outpath(
        flake_store_path,
    )
    logging.info(f"Latest NixOS generation path: '{latest_nixos_generation_outpath}'")

    nix_build_process = subprocess.run(
        [
            "nix",
            "build",
            "--refresh",
            "--no-link",
            "--keep-going",
            "--max-jobs",
            "0",
            latest_nixos_generation_outpath,
        ],
        check=False,
    )
    if nix_build_process.returncode != 0:
        logging.warning(
            f"`{latest_nixos_generation_outpath}` is not fully cached yet",
        )
        sys.exit(0)
    else:
        nixos_rebuild_process = subprocess.run(
            [
                "nixos-rebuild",
                "boot",
                "--show-trace",
                "--print-build-logs",
                "--flake",
                f"{flake_store_path}#{nixos_machine_hostname}",
            ],
            check=False,
        )
        sys.exit(nixos_rebuild_process.returncode)


if __name__ == "__main__":
    main()
