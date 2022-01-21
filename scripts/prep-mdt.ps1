#create a tmp work folder
Write-Host "creating a temp folder..."
mkdir c:\tmp -force
cd c:\tmp

#Enable MDT feature
Write-Host "installing WDS features..."
Install-WindowsFeature WDS-Deployment,WDS-AdminPack

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


Write-Host "add MDT PS Snap-in...to WinPS"
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

#installing PS7
$pwsh7 = "C:\Program Files\PowerShell\7\pwsh.exe"
if (!(Test-Path $pwsh7)){
    Write-Host "installing pwsh 7..."
    curl -Uri https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/PowerShell-7.2.1-win-x64.msi -outfile c:\tmp\ps7.msi
    .\ps7.msi /quiet
    sleep 60
}

 


Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
New-PSDrive -Name "DS001" -PSProvider MDTProvider -Root "C:\MDTDeploymentShare$"

Mount-DiskImage -ImagePath "C:\iso\win10_ent.iso"
Get-DiskImage -DevicePath \\.\CDROM0 | Get-Volume

#importing OS from WIM or DVD
import-mdtoperatingsystem -path "DS001:\Operating Systems" -SourceFile "D:\sources\install.wim" -DestinationFolder "win10" -Verbose
import-mdttasksequence -path "DS001:\Task Sequences" -Name "test" -Template "c:\iso\bin\ts.xml" -Comments "" -ID "1" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows 10 Enterprise Evaluation in win10 install.wim" -FullName "win10_eva" -OrgName "Vagrant" -HomePage "about:blank" -AdminPassword "vagrant" -Verbose

#update the deployment share from the previous step
Update-MDTDeploymentShare -Path "DS001:\"

#creating the media
new-item -path "DS001:\Media" -enable "True" -Name "MEDIA001" -Comments "" -Root "$HOME\Desktop" -SelectionProfile "Everything" -SupportX86 "False" -SupportX64 "True" -GenerateISO "True" -ISOName "shawn_Win10_eva.iso" -Verbose
new-PSDrive -Name "MEDIA001" -PSProvider "MDTProvider" -Root "$HOME\Desktop\Content\Deploy" -Description "Embedded media deployment share" -Force -Verbose

#import the custom settings for TS
Copy-Item -Path "c:\iso\bin\CustomSettings.ini" -Destination "$HOME\desktop\content\Deploy\Control\CustomSettings.ini" -Force
Copy-Item -Path "c:\iso\bin\Bootstrap.ini" -Destination "$HOME\desktop\content\Deploy\Control\Bootstrap.ini" -Force

#import a custom script for disk wiping during winPE
new-item -ItemType directory -Path "C:\MDTDeploymentShare$\pe" -Force
Copy-Item -Path "c:\iso\bin\promptForDiskWipe.bat" -Destination "C:\MDTDeploymentShare$\pe" -Force
Copy-Item -Path "c:\iso\bin\Unattend.xml" -Destination "C:\MDTDeploymentShare$\pe" -Force
Copy-Item -Path "c:\iso\bin\Settings.xml" -Destination "$HOME\desktop\content\Deploy\Control\" -Force


Update-MDTMedia -path "DS001:\Media\MEDIA001" -Verbose


 
