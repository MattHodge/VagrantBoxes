# Install
choco install mssqlserver2014express -y
choco install octopusdeploy -y

$OctoExe = "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe"
# Configure octopusdeploy
Start-Process -FilePath $OctoExe -ArgumentList 'create-instance --instance "OctopusServer" --config "C:\Octopus\OctopusServer.config" --console' -Wait -NoNewWindow
Start-Process -FilePath $OctoExe -ArgumentList ('configure --instance "OctopusServer" --home "C:\Octopus" --storageConnectionString "Data Source=.\SQLEXPRESS;Initial Catalog=Octopus;Integrated Security=True" --upgradeCheck "True" --upgradeCheckWithStatistics "True" --webAuthenticationMode "UsernamePassword" --webForceSSL "False" --webListenPrefixes "http://localhost:80/" --commsListenPort "10943" --serverNodeName "' + $env:COMPUTERNAME + '" --console') -Wait -NoNewWindow
Start-Process -FilePath $OctoExe -ArgumentList 'database --instance "OctopusServer" --create --grant "NT AUTHORITY\SYSTEM" --console' -Wait -NoNewWindow
Start-Process -FilePath $OctoExe -ArgumentList 'service --instance "OctopusServer" --stop --console' -Wait -NoNewWindow
Start-Process -FilePath $OctoExe -ArgumentList 'admin --instance "OctopusServer" --username "Administrator" --email "admin@vagrant.com" --password "OctoVagrant!" --console' -Wait -NoNewWindow
Start-Process -FilePath $OctoExe -ArgumentList 'license --instance "OctopusServer" --licenseBase64 "PExpY2Vuc2UgU2lnbmF0dXJlPSJPeUR6ejVqc1Bpd1ZEcURNU2xRNno5ZDVkbXMwYW1PRHVOQkE1Tm82c3I2akxpdWVXTTNZOXdpQUhRMlNoRHlUOHRzeGR2Z1NXZm9tV2FiL0hJeTJyUT09Ij4KICA8TGljZW5zZWRUbz5WYWdyYW50IEluYzwvTGljZW5zZWRUbz4KICA8TGljZW5zZUtleT41MjY1My0wMzc0Mi05MzQyNC02MjMzNjwvTGljZW5zZUtleT4KICA8VmVyc2lvbj4yLjA8IS0tIExpY2Vuc2UgU2NoZW1hIFZlcnNpb24gLS0+PC9WZXJzaW9uPgogIDxWYWxpZEZyb20+MjAxNy0wMi0wNjwvVmFsaWRGcm9tPgogIDxWYWxpZFRvPjIwMTctMDMtMjM8L1ZhbGlkVG8+CiAgPFByb2plY3RMaW1pdD5VbmxpbWl0ZWQ8L1Byb2plY3RMaW1pdD4KICA8TWFjaGluZUxpbWl0PlVubGltaXRlZDwvTWFjaGluZUxpbWl0PgogIDxVc2VyTGltaXQ+VW5saW1pdGVkPC9Vc2VyTGltaXQ+CjwvTGljZW5zZT4=" --console' -Wait -NoNewWindow
Start-Process -FilePath $OctoExe -ArgumentList 'service --instance "OctopusServer" --install --reconfigure --start --dependOn "MSSQL$SQLEXPRESS" --console' -Wait -NoNewWindow

# Function Register-OctopusTentacle([string]$EnvironmentName, [string]$AppRole, [string]$OctopusServerThumbprint, [string]$OctopusAPIKey, [string]$Localhostname){

#     $TentacleRegistrator = 'register-with --instance "Tentacle" --server "http://localhost" --apiKey={0} --role "{1}" --environment "{2}" --comms-style TentaclePassive --name="{3}" --console --force --publicHostName="{3}"' -f $OctopusAPIKey, $AppRole, $Environmentname, $localhostname

#     Start-Process -FilePath "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" -ArgumentList "create-instance --instance ""Tentacle"" --config ""C:\Octopus\Tentacle.config"" --console"  -Wait -NoNewWindow
#     Start-Process -FilePath "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" -ArgumentList "new-certificate --instance ""Tentacle"" --if-blank --console"  -Wait -NoNewWindow
#     Start-Process -FilePath "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" -ArgumentList "configure --instance ""Tentacle"" --reset-trust --console"  -Wait -NoNewWindow
#     Start-Process -FilePath "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" -ArgumentList "configure --instance ""Tentacle"" --home ""C:\Octopus"" --app ""C:\Octopus\Applications"" --port ""10933"" --console"  -Wait -NoNewWindow
#     Start-Process -FilePath "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" -ArgumentList "configure --instance ""Tentacle"" --trust '$($OctopusServerThumbprint)' --console" -Wait -NoNewWindow
#     Start-Process -FilePath "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" -ArgumentList $TentacleRegistrator -Wait -NoNewWindow
#     Start-Process -FilePath "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" -ArgumentList "service --instance ""Tentacle"" --install --start --console" -Wait -NoNewWindow

#     netsh advfirewall firewall add rule "name=Octopus Deploy Tentacle" dir=in action=allow protocol=TCP localport=10933

#     Restart-Service 'OctopusDeploy Tentacle'

#     Set-Service -Name 'OctopusDeploy Tentacle' -StartupType Automatic
# }

# Register-OctopusTentacle -EnvironmentName 'testing' -AppRole 'octopus-server' -OctopusServerThumbprint $DecryptedValues.OctopusServerThumbprint -OctopusAPIKey $DecryptedValues.OctopusAPIKey -Localhostname $env:COMPUTERNAME
