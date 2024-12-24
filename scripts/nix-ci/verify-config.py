#!/usr/bin/env python3

import asyncio
import subprocess
import sys

nixos_systems = [
    ".#isoImages.aarch64-linux.lts",
    ".#isoImages.aarch64-linux.latest",
    ".#isoImages.aarch64-linux.testing",
    ".#isoImages.riscv64-linux.lts",
    ".#isoImages.riscv64-linux.latest",
    ".#isoImages.riscv64-linux.testing",
    ".#isoImages.x86_64-linux.lts",
    ".#isoImages.x86_64-linux.latest",
    ".#isoImages.x86_64-linux.testing",
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
    nix_eval_cmd = [ 'nix', 'eval', '--apply', 'builtins.attrNames', eval_string ]
    proc = await asyncio.get_event_loop().run_in_executor(
        None,
        lambda: subprocess.run(nix_eval_cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
    )
    return [eval_string, proc.stdout.strip()]

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
