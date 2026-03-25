{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1526-9BDF";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/77fbc35b-9414-4568-a993-d73440037e14";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/0ad8829d-86a2-40c9-bc47-4a3e87ccdbcd";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/7524054e-d267-427a-9830-63225c3e10fb";
  };
}
