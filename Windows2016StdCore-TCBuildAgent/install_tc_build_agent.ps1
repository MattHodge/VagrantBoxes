Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Set-ExecutionPolicy RemoteSigned -Force

choco install teamcityagent -params "serverurl=$($env:TEAMCITY_HOST_URL)" -y
choco install git -y
choco install packer -y
choco install virtualbox -y
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Git\usr\bin", "Machine")
