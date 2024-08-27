{ nixosSystem, ... }:

{
  services.getty.autologinUser = nixosSystem.systemUser.username;
}
