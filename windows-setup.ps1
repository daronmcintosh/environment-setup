function Update-Profile {
  Write-Output "updating profile"
  # create powershell profile if not exists: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.3
  if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
  }
  Install-Module -Name PowerShellGet -Force
  Install-Module -Name Terminal-Icons -Repository PSGallery
  Start-Process -Verb RunAs powershell.exe "Install-Module PSReadLine -AllowPrerelease -Force"

  @"
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\powerlevel10k_lean.omp.json" | Invoke-Expression
Import-Module -Name Terminal-Icons
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
"@ >> $PROFILE
}

function Install-Fonts {
  Write-Output "installing fonts"

  Invoke-WebRequest -URI "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/FiraCode.zip" -Out FiraCode.zip
  mkdir ~/Downloads/Fonts
  Expand-Archive FiraCode.zip -DestinationPath ~/Downloads/Fonts -Force

  $fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
  foreach ($file in Get-ChildItem ~/Downloads/Fonts/*.ttf) {
    $fileName = $file.Name
    if (-not(Test-Path -Path "C:\Windows\fonts\$fileName" )) {
      Write-Output $fileName
      Get-ChildItem $file | ForEach-Object { $fonts.CopyHere($_.fullname) }
    }
  }
  Copy-Item ~/Downloads/Fonts/*.ttf c:\windows\fonts\
}

function Install-Packages {
  Write-Output "installing packages"
  # winget comes bundled in modern versions of windows: https://learn.microsoft.com/en-us/windows/package-manager/winget/
  # TODO: download file from github then import then delete
  # rancher desktop is a bit buggy at the moment so we'll stick with docker desktop for now
  # winget import --import-file winstall.json
  # winget install -e --id Google.Chrome
  # winget install -e --id Microsoft.WindowsTerminal
  winget install -e --id JanDeDobbeleer.OhMyPosh
  winget install -e --id Microsoft.VisualStudioCode
}

function Install-WSL {
  Write-Output "installing wsl"
  # install wsl
  # wsl --install

  # install distro from tar file. distro has default user, daron, and linux-setup.sh was already ran in it
  # wsl --import BaseUbuntu BaseUbuntu .\ubuntu-22.04.tar

}

function Main {
  # run script as administrator
  if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
  }

  Update-Profile
  Install-Fonts
  # Install-Packages
  # Install-WSL
}

Main
