# environment-setup

## linux

```sh
bash <(curl -s https://raw.githubusercontent.com/daronmcintosh/environment-setup/main/linux-setup.sh)
```

### test with docker

1. clone repo
2. run:

```sh
docker build --progress=plain -t foo . && docker run --rm -it foo
```

## windows

```ps1
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/daronmcintosh/environment-setup/main/windows-setup.ps1'))
```

### test with windows sandbox

install winget in sandbox (https://learn.microsoft.com/en-us/windows/package-manager/winget/#install-winget-on-windows-sandbox):

```ps1
Invoke-WebRequest -Uri https://github.com/microsoft/winget-cli/releases/download/v1.3.2691/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -OutFile .\MicrosoftDesktopAppInstaller_8wekyb3d8bbwe.msixbundle
Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage MicrosoftDesktopAppInstaller_8wekyb3d8bbwe.msixbundle
```
