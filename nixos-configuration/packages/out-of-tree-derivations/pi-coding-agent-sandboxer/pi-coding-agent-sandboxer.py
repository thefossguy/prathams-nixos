#!/usr/bin/env python3

import argparse
import logging
import os
import pathlib
import shutil
import sys

USER_HOME_DIR = pathlib.Path.home()
TEMP_DIR = f"{USER_HOME_DIR}/.tmp/coding-agent"

LSM_RO_FILE_PERMS = {"read-file"}
LSM_EXEC_PERMS = {
    "execute",
} | LSM_RO_FILE_PERMS
LSM_RO_DIR_PERMS = {
    "read-dir",
} | LSM_RO_FILE_PERMS
LSM_RW_FILE_PERMS = {"write-file", "make-reg", "remove-file", "make-sym", "refer", "truncate"} | LSM_RO_FILE_PERMS
LSM_RW_DIR_PERMS = {"make-dir", "remove-dir"} | LSM_RO_FILE_PERMS | LSM_RW_FILE_PERMS | LSM_RO_DIR_PERMS


def make_landlock_lsm_rule(lsm_perms: set[str], path_to_sandbox: str) -> list[str]:
    return ["--landlock-rule", f"path-beneath:{','.join(sorted(list(lsm_perms)))}:{path_to_sandbox}"]


def parse_cli_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser()

    # pi
    parser.add_argument("--session", default="")
    parser.add_argument("--fork", default="")
    parser.add_argument("--no-session", action="store_true", default=False)
    parser.add_argument("--pi-env", action="append", default=[])

    # sandboxing
    parser.add_argument("--ro-path", action="append", default=[])
    parser.add_argument("--rw-path", action="append", default=[])
    parser.add_argument("--rw-pwd", action="store_true", default=False)
    parser.add_argument("--tmpdir", default=TEMP_DIR)

    # overrides
    parser.add_argument("--setpriv-bin", default="setpriv")
    parser.add_argument("--pi-bin", default="pi")

    cli_args = parser.parse_args()

    if not shutil.which(cli_args.pi_bin):
        if cli_args.pi_bin == "pi":
            logging.error("The binary 'pi' doesn't exist in $PATH, please override it with `--pi-bin <binary>`")
            sys.exit(1)
        else:
            logging.error(f"The specified `pi` binary '{cli_args.pi_bin}' doesn't exist")
            sys.exit(1)

    if not shutil.which(cli_args.setpriv_bin):
        if cli_args.setpriv_bin == "setpriv":
            logging.error(
                "The binary 'setpriv' doesn't exist in $PATH, please override it with `--setpriv-bin <binary>`"
            )
            sys.exit(1)
        else:
            logging.error(f"The specified `setpriv` binary '{cli_args.setpriv_bin}' doesn't exist")
            sys.exit(1)

    if cli_args.session and cli_args.fork:
        logging.error("`--session` and `--fork` are mutually exclusive")
        sys.exit(1)

    return cli_args


def construct_landlock_sandbox(cli_args: argparse.Namespace) -> list[str]:
    sandboxed_pi_coding_agent_command = (
        [
            cli_args.setpriv_bin,
            "--no-new-privs",
            "--landlock-access",
            "fs",
        ]
        # General Nix + NixOS rules
        + make_landlock_lsm_rule(LSM_EXEC_PERMS | LSM_RO_DIR_PERMS, "/nix/store")
        + make_landlock_lsm_rule(LSM_EXEC_PERMS | LSM_RO_DIR_PERMS, "/run/current-system")
        + make_landlock_lsm_rule(LSM_EXEC_PERMS | LSM_RO_DIR_PERMS, "/run/booted-system")
        + make_landlock_lsm_rule(LSM_EXEC_PERMS | LSM_RO_DIR_PERMS, f"{USER_HOME_DIR}/.nix-profile/bin")
        + make_landlock_lsm_rule(LSM_EXEC_PERMS | LSM_RO_DIR_PERMS, f"{USER_HOME_DIR}/.local/state/home-manager")
        + make_landlock_lsm_rule(LSM_EXEC_PERMS | LSM_RO_DIR_PERMS, f"{USER_HOME_DIR}/.local/state/nix/profiles")
        # pi-coding-agent
        + make_landlock_lsm_rule(LSM_RW_DIR_PERMS, f"{USER_HOME_DIR}/.config/pi")
        + make_landlock_lsm_rule(LSM_RW_DIR_PERMS, f"{USER_HOME_DIR}/.pi")
        # git
        + make_landlock_lsm_rule(LSM_RO_FILE_PERMS, "/etc/gitconfig")
        + make_landlock_lsm_rule(LSM_RO_FILE_PERMS, "/etc/static/gitconfig")
        + make_landlock_lsm_rule(LSM_RO_FILE_PERMS, f"{USER_HOME_DIR}/.gitconfig")
        # TMPDIR
        + make_landlock_lsm_rule(LSM_EXEC_PERMS | LSM_RW_DIR_PERMS, cli_args.tmpdir)
    )

    if cli_args.rw_pwd:
        sandboxed_pi_coding_agent_command.extend(
            make_landlock_lsm_rule(LSM_RW_DIR_PERMS, os.getcwd()),
        )
    else:
        sandboxed_pi_coding_agent_command.extend(
            make_landlock_lsm_rule(LSM_RO_DIR_PERMS, os.getcwd()),
        )
    for rw_path in cli_args.rw_path:
        if os.path.exists(rw_path):
            sandboxed_pi_coding_agent_command.extend(
                make_landlock_lsm_rule(LSM_RW_DIR_PERMS, rw_path),
            )
        else:
            logging.error(f"path '{rw_path}' doesn't exist")
            sys.exit(1)

    for ro_path in cli_args.ro_path:
        if os.path.exists(ro_path):
            sandboxed_pi_coding_agent_command.extend(
                make_landlock_lsm_rule(LSM_RO_DIR_PERMS, ro_path),
            )
        else:
            logging.error(f"path '{ro_path}' doesn't exist")
            sys.exit(1)

    return sandboxed_pi_coding_agent_command


def main() -> int:
    cli_args = parse_cli_arguments()

    if not os.path.exists(cli_args.tmpdir):
        os.makedirs(cli_args.tmpdir)

    sandboxed_pi_coding_agent_command = construct_landlock_sandbox(cli_args)

    pi_coding_agent_command = [cli_args.pi_bin]
    if cli_args.session:
        pi_coding_agent_command.extend(
            [
                "--session",
                cli_args.session,
            ]
        )
    if cli_args.fork:
        pi_coding_agent_command.extend(
            [
                "--fork",
                cli_args.fork,
            ]
        )
    if cli_args.no_session:
        pi_coding_agent_command.extend(["--no-session"])

    process_command = sandboxed_pi_coding_agent_command + ["--"] + pi_coding_agent_command
    current_env = os.environ.copy()
    current_env["PI_OFFLINE"] = "1"
    current_env["PI_SKIP_VERSION_CHECK"] = "1"
    current_env["PI_TELEMETRY"] = "1"
    current_env["TMPDIR"] = cli_args.tmpdir
    for specified_env in cli_args.pi_env:
        env_var_name = specified_env.split("=")[0]
        env_var_value = "=".join(specified_env.split("=")[1:])
        current_env[env_var_name] = env_var_value

    print(f"+ {' '.join(process_command)}")
    print(process_command)
    os.execvpe(cli_args.setpriv_bin, process_command, current_env)


if __name__ == "__main__":
    sys.exit(main())
