{ systemUser, ... }:

{
  security.sudo.extraRules = [{
    users = [ systemUser.username ];
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" ];
    }];
  }];
}
