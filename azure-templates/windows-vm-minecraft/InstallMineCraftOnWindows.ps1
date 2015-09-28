# Script to download and install Minecraft server on a clean Windows machine
# This script does the following:
#   - Install chocolatey
#   - Download and Install Minecraft client
#   - Install Java runtime
#   - Download Minecraft server JAR
#   - Start Minecraft server (future version will create a Windows service)

$minecraftVersion = "1.8.8"
$minecraftJar = "minecraft_server." + $minecraftVersion + ".jar"
$javaInstaller = "http://javadl.sun.com/webapps/download/AutoDL?BundleId=109717"
$javasetupfile = "jre-8u60-windows-i586-iftw.exe"
$clientExe = "MinecraftInstaller.msi"
$clientURL = "https://launcher.mojang.com/download/" + $clientExe
$webclient = New-Object System.Net.WebClient
$minecraftServerPath = $env:USERPROFILE + "\minecraft_server\"

# install chocolatey resource
register-packagesource -Name chocolatey -Provider PSModule -Trusted -Location http://chocolatey.org/api/v2/ -Force
 
# download Minecraft client
$filePath = $env:USERPROFILE + "\Downloads\" + $clientExe
wget -Uri "$clientURL" -OutFile $filePath 

# install Minecraft client 
msiexec /quiet /i $filePath

# install java via Chocolatey 
#Find-Package -name javaruntime | install-package -Force # does not seem to work.
# Download Jave Installer
$filePath = $env:USERPROFILE + "\Downloads\" + $javasetupfile
wget -Uri "$javaInstaller" -OutFile $filePath 

#Install java client
iex "$filePath /s"

#Wait for installation java installation to finish
while (get-process -name jre-8u60-windows-i586-iftw -ErrorAction SilentlyContinue)
{'...waiting to finish install...';sleep 5 }

# reload PATH
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine")
$javaCommand = get-command java.exe
$javaPath = $javaCommand.Name
$jarPath = $minecraftServerPath + $minecraftJar

# download Minecraft server
md $minecraftServerPath

$url = "https://s3.amazonaws.com/Minecraft.Download/versions/" + $minecraftVersion + "/" + $minecraftJar
wget -Uri "$URL" -OutFile $jarpath 

# launch Minecraft server for first time
cd $minecraftServerPath

md logs
echo $null > server.properties
out-file -filepath .\banned-ips.json -encoding ascii -inputobject "[]`n"
out-file -filepath .\banned-players.json -encoding ascii -inputobject "[]`n"
out-file -filepath .\ops.json -encoding ascii -inputobject "[]`n"
out-file -filepath .\usercache.json -encoding ascii -inputobject "[]`n"
out-file -filepath .\whitelist.json -encoding ascii -inputobject "[]`n"

out-file -filepath .\eula.txt -encoding ascii -inputobject "eula=true`n"
iex "$javaPath -Xmx1024M -Xms1024M -jar $jarPath nogui"

