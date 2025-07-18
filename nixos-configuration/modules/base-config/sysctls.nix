{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

{
  boot.kernel.sysctl = {
    ## Z-RAM-Swap
    # Kernel docs: https://docs.kernel.org/admin-guide/sysctl/vm.html
    # Pop!_OS "docs": https://github.com/pop-os/default-settings/pull/163/files
    # Using zramswap, penalty shouldn't be that high, since if you are under
    # high memory pressure, you likely are under high CPU load too
    # at which point, you are performing computations and latency goes moot.
    "vm.swappiness" = 180;
    # Since zramSwap.algorithm is set to 'zstd', it is recommeded to set the
    # 'vm.page-cluster' paramater to '0'.
    "vm.page-cluster" = 0;
    # Ensure that at-least 512MBytes of total memory is free to avoid system freeze.
    # Not sure about the 512MBytes value since Pop!_OS sets it to 0.01% of total memory,
    # which is roughly equal to 3.7MBytes on a 3700MBytes RPi4. The value of 512MBytes
    # also does not leave lee-way for a 512M RPi Zero.
    # A value too LOW  will result in system freeze.
    # A value too HIGH will result in OOM faster.
    "vm.min_free_kbytes" = 512000;
    # Disable 'vm.wwatermark_scale_factoratermark_boost_factor'.
    # https://groups.google.com/g/linux.debian.user/c/YcDYu-jM-to
    "vm.watermark_boost_factor" = 0;
    # Start swapping when 70% of memory is full (30% of memory is left).
    # 3000 is the MAX
    "vm.watermark_scale_factor" = 3000;
    # Increase the number of maximum mmaps a process may have (ZFS).
    # 2147483642 = 1.99-ish GiB
    "vm.max_map_count" = 2147483642;

    # Same as `vm.dirty_ratio` but for background tasks
    "vm.dirty_background_ratio" = 10;
    # After how many centiseconds (1 second = 100 centiseconds) is dirty data
    # committed to the disk
    "vm.dirty_expire_centisecs" = 3000;
    # Percentage of memory allowed to be filled with dirty data until it is
    # committed to the disk
    "vm.dirty_ratio" = 20;
    # Interval between the kernel flusher threads that wake up to write old
    # data to the disk. **Try keeping this less than half of whatever
    # `vm.dirty_expire_centisecs`.**
    # Check every N centisecs if data needs to be committed to the disk or not.
    "vm.dirty_writeback_centisecs" = 1000;

    # format for `kernel.printk`:
    # 1. Console log-level (messages lower than X are printed)
    # 2. Default log-level for messages without an explicit log-level specified
    # 3. Lowest possible log-level (can't set X lower than this value)
    # 4. Console log-level at boot-time
    "kernel.printk" =
      let
        # use `KERN_DEBUG` (7) log-level for VMs booting dev kernels
        # use `KERN_INFO` (6) for everyone else
        consoleLogLevel = if config.customOptions.kernelDevelopment.virt.enable then "7" else "6";
      in
      "${consoleLogLevel} 4 3 7";

    # The Magic SysRq key is a key combo that allows users connected to the
    # system console of a Linux kernel to perform some low-level commands.
    # Disable it, since we don't need it, and is a potential security concern.
    "kernel.sysrq" = 0;

    ## TCP hardening
    # Prevent bogus ICMP errors from filling up logs.
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    # Reverse path filtering causes the kernel to do source validation of
    # packets received from all interfaces. This can mitigate IP spoofing.
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.all.rp_filter" = 1;
    # Do not accept IP source route packets (we're not a router)
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    # Don't send ICMP redirects (again, we're on a router)
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    # Refuse ICMP redirects (MITM mitigations)
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    # Protects against SYN flood attacks
    "net.ipv4.tcp_syncookies" = 1;
    # Incomplete protection again TIME-WAIT assassination
    "net.ipv4.tcp_rfc1337" = 1;

    ## TCP optimization
    # TCP Fast Open is a TCP extension that reduces network latency by packing
    # data in the sender’s initial TCP SYN. Setting 3 = enable TCP Fast Open for
    # both incoming and outgoing connections:
    "net.ipv4.tcp_fastopen" = 3;
    # Bufferbloat mitigations + slight improvement in throughput & latency
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "cake";

    ## Allow rootless containers to get pinged and/or ping each other
    "net.ipv4.ping_group_range" = "0 165536";

    ## Taken from [nix-mineral](https://github.com/cynicsketch/nix-mineral)
    "dev.tty.ldisc_autoload" = 0;
    "fs.protected_fifos" = 2;
    "fs.protected_hardlinks" = 1;
    "fs.protected_regular" = 2;
    "fs.protected_symlinks" = 1;
    "fs.suid_dumpable" = 0;
    "kernel.dmesg_restrict" = 1;
    "kernel.io_uring_disabled" = 1;
    "kernel.kexec_load_disabled" = 1;
    "kernel.kptr_restrict" = 2;
    "kernel.randomize_va_space" = 2;
    "kernel.unprivileged_bpf_disabled" = 1;
    "kernel.yama.ptrace_scope" = 1;
    "net.core.bpf_jit_harden" = 2;
    "net.ipv4.conf.all.arp_announce" = 2;
    "net.ipv4.conf.default.arp_announce" = 2;
    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.conf.default.log_martians" = 1;
    "net.ipv4.conf.all.shared_media" = 0;
    "net.ipv4.conf.default.shared_media" = 0;
    "vm.mmap_min_addr" = 65536; # 64KB
    "vm.mmap_rnd_compat_bits" = 16;
    "vm.unprivileged_userfaultfd" = 0;
  };
}
