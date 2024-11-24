#!/usr/bin/env python3

import asyncio
import subprocess
import sys

nixos_systems = [
    ".#isoImages.aarch64-linux.nozfs",
    ".#isoImages.aarch64-linux.zfs",
    ".#isoImages.riscv64-linux.nozfs",
    ".#isoImages.riscv64-linux.zfs",
    ".#isoImages.x86_64-linux.nozfs",
    ".#isoImages.x86_64-linux.zfs",
    ".#nixosConfigurations.bheem",
    ".#nixosConfigurations.bhim",
    ".#nixosConfigurations.chaturvyas",
    ".#nixosConfigurations.flameboi",
    ".#nixosConfigurations.indra",
    ".#nixosConfigurations.madhav",
    ".#nixosConfigurations.mahadev",
    ".#nixosConfigurations.matsya",
    ".#nixosConfigurations.pawandev",
    ".#nixosConfigurations.raajan",
    ".#nixosConfigurations.reddish",
    ".#nixosConfigurations.sentinel",
    ".#nixosConfigurations.stuti",
    ".#nixosConfigurations.vaaman",
    ".#nixosConfigurations.vaayu",
]

async def print_eval_val(nixosSystem, config) -> None:
    eval_string = nixosSystem + ".config." + config
    nix_eval_cmd = "nix eval " + eval_string
    if "home-manager" in config:
        return [eval_string, "<EMPTY>"]
    else:
        proc = await asyncio.get_event_loop().run_in_executor(
            None,
            lambda: subprocess.check_output(nix_eval_cmd, shell=True)
        )
        return [eval_string, proc.decode().strip()]

async def print_val(config):
    tasks = [ print_eval_val(nixosSystem, config) for nixosSystem in nixos_systems ]
    results = await asyncio.gather(*tasks)
    results.sort()
    for result in results:
        print("{}: {}".format(result[0], result[1]))
    print('-' * 80)
    return

async def main():
    for config in sys.argv[1:]:
        await print_val(config)
    return

if __name__ == "__main__":
    asyncio.run(main())
