#Setting the parameters
$MDTShareName = "DS001"
$MDTSharePath = $MDTShareName + ":\"
$MDTShareRoot = "c:\MDTDeploymentShare$"
$Syncedfolder = "c:\iso\"
$ISOName = "win10_ent.iso"
$TemplatePath = "c:\iso\bin\"
$OfflineMediaRoot = "$HOME\Desktop"
$OfflineMediaName = "MEDIA001"
$OutISO = "shawn_Win10_eva.iso"

Write-Host "Configuring MDT..."

Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
New-PSDrive -Name $MDTShareName -PSProvider MDTProvider -Root $MDTShareRoot

#mounting the OS ISO for WIM extraction
Write-Host "Mounting the ISO for WIM extraction..."
Mount-DiskImage -ImagePath "$Syncedfolder$isoname"
Get-DiskImage -DevicePath \\.\CDROM0 | Get-Volume

#importing OS from WIM or DVD
Write-Host "Importing WIM..."
import-mdtoperatingsystem -path ($MDTSharePath + 'Operating Systems') -SourceFile "D:\sources\install.wim" -DestinationFolder "win10" -Verbose

#importing a TS template pre configured
Write-Host "Importing customised Task Sequence..."
$WIMName = (gci ($MDTSharePath+'operating systems')).name
import-mdttasksequence -path ($MDTSharePath + 'Task Sequences') -Name "test" -Template ($TemplatePath+'ts.xml') -Comments "" -ID "1" -Version "1.0" -OperatingSystemPath ($MDTSharePath+"Operating Systems\$WIMName") -FullName "win10_eva" -OrgName "Vagrant" -HomePage "about:blank" -AdminPassword "vagrant" -Verbose

#creating the media
Write-Host "Creating the offline media..."
new-item -path ($MDTSharePath+'Media') -enable "True" -Name $OfflineMediaName -Comments "" -Root $offlineMediaRoot -SelectionProfile "Everything" -SupportX86 "False" -SupportX64 "True" -GenerateISO "True" -ISOName $OutISO -Verbose
new-PSDrive -Name $OfflineMediaName -PSProvider "MDTProvider" -Root "$offlineMediaRoot\Content\Deploy" -Description "Embedded media deployment share" -Force -Verbose

#import the custom settings for TS
Write-Host "Importing customised settings of offline media..."
Copy-Item -Path ($TemplatePath+'CustomSettings.ini') -Destination "$offlineMediaRoot\content\Deploy\Control\CustomSettings.ini" -Force
Copy-Item -Path ($TemplatePath+'Bootstrap.ini') -Destination "$offlineMediaRoot\content\Deploy\Control\Bootstrap.ini" -Force

#import a custom script for disk wiping during winPE
#Write-Host "Adding the disk wipe script..."
#new-item -ItemType directory -Path "$MDTShareRoot\pe" -Force
#Copy-Item -Path ($TemplatePath+'promptForDiskWipe.bat') -Destination "$MDTShareRoot\pe" -Force
#Copy-Item -Path ($TemplatePath+'Unattend.xml') -Destination "$MDTShareRoot\pe" -Force
#Copy-Item -Path ($TemplatePath+'Settings.xml') -Destination "$offlineMediaRoot\content\Deploy\Control\" -Force

#update the deployment share from the previous step
Update-MDTDeploymentShare -Path $MDTSharePath

#burn the ISO
Write-Host "Producing the ISO..."
Update-MDTMedia -path ($MDTSharePath+"Media\$OfflineMediaName") -Verbose

#ship the ISO to synced folder on your work machine
Write-Host "Shipping the ISO to synced folder..."
Copy-Item -Path ($offlineMediaRoot +"\" + $OutISO) -Destination $Syncedfolder -Force -Verbose