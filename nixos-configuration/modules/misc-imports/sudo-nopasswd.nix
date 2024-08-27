{ nixosSystem, ... }:

{
  security.sudo.extraRules = [{
    users = [ nixosSystem.systemUser.username ];
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" ];
    }];
  }];
}
