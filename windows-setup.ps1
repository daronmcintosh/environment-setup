# TODO: fail if not admin?
# winget comes bundled in modern versions of windows: https://learn.microsoft.com/en-us/windows/package-manager/winget/

# create powershell profile if not exists: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.3
if (!(Test-Path -Path $PROFILE)) {
  New-Item -ItemType File -Path $PROFILE -Force
}

# TODO: download file from github then import then delete
# rancher desktop is a bit buggy at the moment so we'll stick with docker desktop for now
# winget import --import-file winstall.json
# winget install -e --id Google.Chrome
winget install -e --id Microsoft.WindowsTerminal
winget install -e --id JanDeDobbeleer.OhMyPosh

# TODO: add following to $PROFILE
# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\powerlevel10k_lean.omp.json" | Invoke-Expression

# install font
Invoke-WebRequest -URI "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/FiraCode.zip" -Out FiraCode.zip
Expand-Archive FiraCode.zip -DestinationPath C:\Windows\fonts -Force

# TODO: should the $PROFILE for powershell file be tracked in git? for loading oh my posh
# TODO: should profile config for windows terminal also be tracked? for setting default font


# install wsl
# wsl --install

# install distro from tar file. distro has default user, daron, and linux-setup.sh was already ran in it
# wsl --import BaseUbuntu BaseUbuntu .\ubuntu-22.04.tar
