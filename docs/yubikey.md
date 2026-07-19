# yubikey

Ensure that a yubikey is inserted:
```bash
ykman list
```

The `ykpersonalize` command writes a secret to the yubikey and accepts only a 40 characters long alpha-numeric key.

**DO NOT USE THIS.** A very simple way to populate the yubikey:
```bash
# prefix the command with a space to not log it into your `~/.bash_history`
 echo -n "$YourSecretPassPhrase" | sha1sum - | cut -d' ' -f1 | ykpersonalize -2 -ochal-resp -ochal-hmac -ohmac-lt64 -oserial-api-visible -y
```

Add a bunch of obfuscation to prevent original passphrase from ever being discovered. OpenSSL is the preferred method:
```bash
# prefix the command with a space to not log it into your `~/.bash_history`
 echo -n "$YourSecretPassPhrase" | \
     openssl kdf -keylen 64 -kdfopt digest:SHA512 -kdfopt pass:stdin -kdfopt salt:yubikey-slot-2-v1 -kdfopt iter:100000000 PBKDF2 | \
     sha1sum - | cut -d' ' -f1 | \
     ykpersonalize -2 -ochal-resp -ochal-hmac -ohmac-lt64 -oserial-api-visible -y
```
