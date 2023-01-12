# TODO: fail if not admin?
# winget comes bundled in modern versions of windows: https://learn.microsoft.com/en-us/windows/package-manager/winget/

# create powershell profile if not exists: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.3
if (!(Test-Path -Path $PROFILE)) {
  New-Item -ItemType File -Path $PROFILE -Force
}
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# TODO: download file from github then import then delete
# rancher desktop is a bit buggy at the moment so we'll stick with docker desktop for now
winget import --import-file winstall.json

# install font
Invoke-WebRequest -URI "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/FiraCode.zip" -Out FiraCode.zip
Expand-Archive FiraCode.zip -DestinationPath C:\Windows\fonts

# install wsl
# install ubuntu from a tar
# run setup linux-setup.sh in container
# wsl --install
