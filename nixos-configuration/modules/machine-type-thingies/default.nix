{ config, lib, ... }:

lib.mkif config.custom-options.isNixosDesktop {
  imports = [ ./desktop.nix ];
}

lib.mkif config.custom-options.isNixosLaptop {
  imports = [ ./laptop.nix ];
}

lib.mkif config.custom-options.isNixosServer {
  imports = [ ./server.nix ];
}
