# LUKS

`CHALLENGE_HEX` + the yubikey's secret = unlock key

The `ykchalresp` command accepts a 64-character long hexadecimal key:
```bash
# prefix the command with a space to not log it into your `~/.bash_history`
 echo -n "$CHALLENGE_STRING" | sha512sum - | cut -d' ' -f1 | ykchalresp -2 -x -i -
```

Create a LUKS-formatted encrypted device:
```bash
# prefix the command with a space to not log it into your `~/.bash_history`
 echo -n "$CHALLENGE_STRING" | sha512sum - | cut -d' ' -f1 | \
     ykchalresp -2 -x -i - | \
     sudo cryptsetup luksFormat --type luks2 --cipher aes-xts-plain64 --key-size 512 --hash sha512 --pbkdf argon2id --pbkdf-memory 1048576 --pbkdf-parallel 1 --iter-time 60000 --use-random --batch-mode --label $LABEL --uuid $UUID --key-file - $BLOCK_DEVICE
```

Open (equivalent of `mount`) the LUKS device:
```bash
# prefix the command with a space to not log it into your `~/.bash_history`
 echo -n "$CHALLENGE_STRING" | sha512sum - | cut -d' ' -f1 | \
     ykchalresp -2 -x -i - | \
     sudo cryptsetup open --key-file - $BLOCK_DEVICE $LABEL
```
