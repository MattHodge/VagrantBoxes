$ErrorActionPreference = 'Stop'

# Install
choco install mssqlserver2014express -y
choco install octopusdeploy -y
choco install octopusdeploy.tentacle -y
choco install octopustools -y

$OctopusUsername = "Administrator"
$OctopusPassword = "OctoVagrant!"

$OctoExe = "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe"

$installCommands = @(
    "create-instance --instance `"OctopusServer`" --config `"C:\Octopus\OctopusServer.config`""
    "database --instance `"OctopusServer`" --connectionString `"Data Source=(local)\SQLEXPRESS;Initial Catalog=Octopus;Integrated Security=True`" --create --grant `"NT AUTHORITY\SYSTEM`""
    "configure --instance `"OctopusServer`" --upgradeCheck `"False`" --upgradeCheckWithStatistics `"False`" --webForceSSL `"False`" --webListenPrefixes `"http://localhost:80/`" --commsListenPort `"10943`" --serverNodeName `"$($env:COMPUTERNAME)`" --usernamePasswordIsEnabled `"True`""
    "service --instance `"OctopusServer`" --stop"
    "admin --instance `"OctopusServer`" --username `"$($OctopusUsername)`" --email `"email@vagrant.com`" --password `"$($OctopusPassword)`""
    "license --instance `"OctopusServer`" --licenseBase64 `"PExpY2Vuc2UgU2lnbmF0dXJlPSJDd0R1YUh2L2JveVBiS2tISnRqdjVBdmRWUjFWdG1zdktrSlZJQTJyM3ZhbDQ4d0lObThLbm1pUHlQRG1TYXNTKzl2OTlGUERNNlc0ZE92SjYvd2IzZz09Ij4KICA8TGljZW5zZWRUbz5WYWdyYW50PC9MaWNlbnNlZFRvPgogIDxMaWNlbnNlS2V5PjI2MDgwLTQ1MDc1LTU1NDIyLTI5NDU3PC9MaWNlbnNlS2V5PgogIDxWZXJzaW9uPjIuMDwhLS0gTGljZW5zZSBTY2hlbWEgVmVyc2lvbiAtLT48L1ZlcnNpb24+CiAgPFZhbGlkRnJvbT4yMDE3LTEyLTAzPC9WYWxpZEZyb20+CiAgPFZhbGlkVG8+MjAxOC0wMS0xNzwvVmFsaWRUbz4KICA8UHJvamVjdExpbWl0PlVubGltaXRlZDwvUHJvamVjdExpbWl0PgogIDxNYWNoaW5lTGltaXQ+VW5saW1pdGVkPC9NYWNoaW5lTGltaXQ+CiAgPFVzZXJMaW1pdD5VbmxpbWl0ZWQ8L1VzZXJMaW1pdD4KPC9MaWNlbnNlPg==`""
    "service --instance `"OctopusServer`" --install --reconfigure --start --dependOn `"MSSQL`$SQLEXPRESS`""
)

foreach ($command in $installCommands) {
    Write-Output "Running $($OctoExe) $($command)"
    Start-Process -FilePath $OctoExe -ArgumentList $command -Wait -NoNewWindow -ErrorAction Stop
}

New-NetFirewallRule -DisplayName 'HTTP(S) Inbound' -Profile @('Domain', 'Private') -Direction Inbound -Action Allow -Protocol TCP -LocalPort @('80', '443')

#############################
# GET API KEY
#############################

$OctopusURI = "http://localhost" #Octopus URL

$APIKeyPurpose = "PowerShell" #Brief text to describe the purpose of your API Key.

#Adding libraries. Make sure to modify these paths acording to your environment setup.
Add-Type -Path "C:\Program Files\Octopus Deploy\Octopus\Newtonsoft.Json.dll"
Add-Type -Path "C:\Program Files\Octopus Deploy\Octopus\Octopus.Client.dll"

#Creating a connection
$endpoint = new-object Octopus.Client.OctopusServerEndpoint $OctopusURI
$repository = new-object Octopus.Client.OctopusRepository $endpoint

#Creating login object
$LoginObj = New-Object Octopus.Client.Model.LoginCommand
$LoginObj.Username = $OctopusUsername
$LoginObj.Password = $OctopusPassword

#Loging in to Octopus
$repository.Users.SignIn($LoginObj)

#Getting current user logged in
$UserObj = $repository.Users.GetCurrent()

#Creating API Key for user. This automatically gets saved to the database.
$ApiObj = $repository.Users.CreateApiKey($UserObj, $APIKeyPurpose)

#############################
# CREATE ENVIRONMENT
#############################

& octo create-environment --name Testing --server http://localhost --apikey $ApiObj.ApiKey

#############################
# INSTALL LOCAL TENTACLE
#############################

# Get octo thumbprint
$thumb = (& $OctoExe show-thumbprint)[-1]

Function Register-OctopusTentacle([string]$EnvironmentName, [string]$AppRole, [string]$OctopusServerThumbprint, [string]$OctopusAPIKey, [string]$Localhostname){

    $TentacleRegistrator = 'register-with --instance "Tentacle" --server "http://localhost" --apiKey={0} --role "{1}" --environment "{2}" --comms-style TentaclePassive --name="{3}" --console --force --publicHostName="{3}"' -f $OctopusAPIKey, $AppRole, $Environmentname, $localhostname

    Start-Process -FilePath "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" -ArgumentList "create-instance --instance ""Tentacle"" --config ""C:\Octopus\Tentacle.config"" --console"  -Wait -NoNewWindow
    Start-Process -FilePath "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" -ArgumentList "new-certificate --instance ""Tentacle"" --if-blank --console"  -Wait -NoNewWindow
    Start-Process -FilePath "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" -ArgumentList "configure --instance ""Tentacle"" --reset-trust --console"  -Wait -NoNewWindow
    Start-Process -FilePath "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" -ArgumentList "configure --instance ""Tentacle"" --home ""C:\Octopus"" --app ""C:\Octopus\Applications"" --port ""10933"" --console"  -Wait -NoNewWindow
    Start-Process -FilePath "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" -ArgumentList "configure --instance ""Tentacle"" --trust '$($OctopusServerThumbprint)' --console" -Wait -NoNewWindow
    Start-Process -FilePath "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" -ArgumentList $TentacleRegistrator -Wait -NoNewWindow
    Start-Process -FilePath "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" -ArgumentList "service --instance ""Tentacle"" --install --start --console" -Wait -NoNewWindow

    netsh advfirewall firewall add rule "name=Octopus Deploy Tentacle" dir=in action=allow protocol=TCP localport=10933

    Restart-Service 'OctopusDeploy Tentacle'

    Set-Service -Name 'OctopusDeploy Tentacle' -StartupType Automatic
}

Register-OctopusTentacle -EnvironmentName 'Testing' -AppRole 'octopus-server' -OctopusServerThumbprint $thumb -OctopusAPIKey $ApiObj.ApiKey -Localhostname $env:COMPUTERNAME
