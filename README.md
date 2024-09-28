# magisk-kernelsu-grant-revoke-permissions
Grant/revoke permissions at startup (only tested with VMs / emulators)

```sh
Create these 2 files
"/sdcard/hansgisk/grant_permissions.txt"
"/sdcard/hansgisk/revoke_permissions.txt"

And add one package name each line, e.g.

net.sourceforge.opencamera
org.fdroid.fdroid
com.termux
com.spotify.com
com.termux.boot

and reboot
```