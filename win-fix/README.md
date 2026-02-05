# Windows 10 Fix

Run `./00-SetExecutionPolicy-Unrestricted.ps1` first.

To run a single script remotely without manually downloading

```powershell
irm "https://github.com/dpi0/scripts/raw/refs/heads/main/win-fix/Services/Disable-WindowsDefender-DependService.ps1" | iex
```

> [!TIP]
> Why do i need to run `./00-SetExecutionPolicy-Unrestricted.ps1` first?
>
> 1. Lowers the execution policy for your user only.
> 2. `Unrestricted` policy tells windows - **Run everything, but warn me when running something downloaded.**
>
> Some scripts might fail (that fall under the default `Restricted` policy) and say *File cannot be loaded because running scripts is disabled on this system.*

## `Services/Disable-WindowsDefender-DependService.ps1`

<https://www.reddit.com/r/Windows10/comments/1hygqe1/comment/m6id128/?context=3>

1. Disable virus protection in Defender manually
2. Boot into safe mode, run `msconfig` in `win+r` then `Boot → Safe boot → Minimal`
3. Run this script in safe mode
4. Reboot normally, run `msconfig` in `win+r` then `Boot → uncheck Safe boot`

## `Tweaks/Fix-SSH-PrivateKey-Permissions.ps1`

1. Update `$keyPath` variable to match your private key file path
2. Default `$keyPath` is `%USERPROFILE%\.ssh\id_rsa`

## `Tweaks/Rename-Computer-And-Reboot.ps1`

1. Update `$newName` variable to set your new computer name
2. Default `$newName` is `windows`

## `Tweaks/Set-StaticWiFi-IP.ps1`

0. Get your current variable values from the command `ipconfig /all`. Look specifically in the `Wireless LAN adapter Wi-Fi:` section at the bottom.
1. Update `$newIPAdress`, `$prefixLength` and `$gateway` variables
2. Default `$newIPAdress` is `192.168.1.60`
3. Default `$prefixLength` is `24`
4. Default `$gateway` is `192.168.1.1`
