# environment-setup

TODO: checkout a solution like https://github.com/daytonaio/daytona which would solve my use cases?

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

### test with windows 11 dev environment
