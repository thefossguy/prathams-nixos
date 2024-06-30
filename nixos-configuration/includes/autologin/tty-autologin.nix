{ systemUser, ... }:

{
  services.getty.autologinUser = systemUser.username;
}
