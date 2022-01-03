#create a tmp work folder
Write-Host "creating a temp folder..."
mkdir c:\tmp -force
cd c:\tmp

#Enable MDT feature
Write-Host "installing WDS features..."
Install-WindowsFeature WDS,WDS-Deployment,WDS-AdminPack

#Install ADK Deployment Tools feature
$adk = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\"
Write-Host "installing ADK.exe..."
if (!(Test-Path $adk)){
    curl -Uri "https://go.microsoft.com/fwlink/?linkid=2165884" -OutFile C:\tmp\adk.exe
    .\adk.exe /features OptionId.DeploymentTools /quiet
    sleep 60
}
else {
    Write-Host "Skipping..ADK installed!"
}


#Install the windows PE mgmt feature
$winpe = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\en-us\winpe.wim"
Write-Host "installing PE.exe..."
if (!(Test-Path $winpe)){
    curl -Uri "https://go.microsoft.com/fwlink/?linkid=2087112" -OutFile C:\tmp\pe.exe
    .\pe.exe /features + /q  
    sleep 20
}
else {
    Write-Host "Skipping..PE installed!"
}


#Install MDT Toolkit feature
$mdtwb = "C:\Program Files\Microsoft Deployment Toolkit\Bin\DeploymentWorkbench.msc"
Write-Host "installing mdt workbench..."
if (!(test-path $mdtwb)) {
    curl -Uri "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi" -outfile c:\tmp\mdt64.msi
    .\mdt64.msi /quiet
    sleep 60
}
else {
    Write-Host "Skipping..MDT Workbench installed!"
}


Write-Host "add MDT PS Snap-in..."
New-Item $PROFILE -ItemType File -Force -Value "Add-PSSnapin -Name Microsoft.BDD.PSSnapIn"


#Create a MDT share
$mdtshare = "C:\MDTDeploymentShare$"
if (!(test-path $mdtshare)) {
    Write-Host "creating MDT Deployment Share"
    New-Item $mdtshare -Type directory  
    ([wmiclass]"win32_share").Create($mdtshare, "MDTDeploymentShare$",0)  
}
#adding the mdt share to workbench
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
new-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root $mdtshare -Description "MDT Deployment Share" -Verbose | add-MDTPersistentDrive -Verbose