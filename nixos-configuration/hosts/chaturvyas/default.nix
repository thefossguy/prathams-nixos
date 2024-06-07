{ ... }:

{
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/3A4D-C659";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/044c375e-e89f-4531-9d58-d4b6650f6774";
    fsType = "xfs";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/f1a133b4-5d19-46a0-b80f-f118ec067567";
    fsType = "xfs";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/0dc6547c-757c-4dbc-aa54-47f44e9c2598";
    fsType = "xfs";
  };
}
