#!/usr/bin/env python3

import sys
import subprocess
import json

U16_MAX = (1 << 16) - 1
nix3_command = [
    "nix",
    "--extra-experimental-features",
    "nix-command",
    "--extra-experimental-features",
    "flakes",
]


def get_hostnames() -> list[str]:
    nix_eval_command = nix3_command + [
        "eval",
        "--json",
        "--apply",
        "builtins.attrNames",
        ".#nixosConfigurations",
    ]
    nix_eval_process = subprocess.run(
        nix_eval_command,
        capture_output=True,
        text=True,
        check=False,
    )
    stdout = nix_eval_process.stdout.strip()
    if not stdout:
        print("ERROR: Could not get the NixOS configurations' names")
        sys.exit(1)
    else:
        data = json.loads(stdout)
        return data


def main():
    all_hostnames = get_hostnames()
    hostnames_and_totals = {}
    for hostname in all_hostnames:
        total = 0
        for hostname_char in hostname:
            add_operand = ord(hostname_char)
            temp_total = total + add_operand
            assert temp_total < U16_MAX, f"total ({temp_total}) is higher than U16_MAX ({U16_MAX})"
            total = temp_total
        total_digits = len(str(total))
        if total_digits < 6:
            extra_digits = 6 - total_digits
            to_append = 0
            total = total * (10**extra_digits)
            for digit in range(1, extra_digits + 1):
                to_append += int((total / 100000) * digit)
            total += (to_append * 10) + to_append
        hostnames_and_totals[hostname] = total
        print(f"{hostname}    \t{total}")

    all_totals = set(hostnames_and_totals.values())
    assert len(all_totals) == len(hostnames_and_totals.values()), "the totals are not unique"
    return


if __name__ == "__main__":
    main()
