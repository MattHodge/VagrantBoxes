$ErrorActionPreference = 'Stop'

Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install teamcityagent -y
choco install git -y
choco install packer -y
choco install virtualbox -y
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Git\usr\bin", "Machine")

$tcAgentConfig = @"
serverUrl=$($env:TEAMCITY_HOST_URL)
name=NESTEDVIRTUALBOX
workDir=../work
tempDir=../temp
systemDir=../system
authorizationToken=
teamcity.agent.provides.virtualbox true
"@

$tcAgentConfig | Out-File -FilePath C:\buildAgent\conf\buildAgent.properties -Encoding ASCII -Force

Restart-Service -Name TCBuildAgent
Start-Service -Name TCBuildAgent
