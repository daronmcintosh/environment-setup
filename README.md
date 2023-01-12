# dotfiles

## how to use

```sh
bash <(curl -s https://raw.githubusercontent.com/daronmcintosh/environment-setup/main/linux-setup.sh)
```

```ps1
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/daronmcintosh/environment-setup/main/windows-setup.ps1'))
```

## test by running (requires docker)

1. clone repo
2. run:

```sh
docker build --progress=plain -t foo . && docker run --rm -it foo
```
