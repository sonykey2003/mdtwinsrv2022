#reconciled 
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
New-PSDrive -Name "DS001" -PSProvider MDTProvider -Root "C:\MDTDeploymentShare$"

### Step 1: WIM Importation & Mounting
Write-Host "Mounting the ISO for WIM extraction..."
$win10iso =  "c:\mdt\win10_ent.iso"
Mount-DiskImage -ImagePath  $win10iso
import-mdtoperatingsystem -path "DS001:\Operating Systems" `
 -SourcePath "D:\" `
 -DestinationFolder "Windows 10 Enterprise Evaluation x64" `
 -Verbose

### Step 2: Force importing the latest version of task sequence tamplate
$TSName = "test"
Write-Host "Purge the existing TS for adopting the latest template..."
Remove-Item  "DS001:\Task Sequences\$TSName"

Write-Host "Importing customised Task Sequence..."
import-mdttasksequence -path "DS001:\Task Sequences" `
 -Name $TSName  `
 -Template "c:\bin\ts.xml" `
 -Comments "" `
 -ID "1" `
 -Version "1.0" `
 -OperatingSystemPath "DS001:\Operating Systems\Windows 10 Enterprise Evaluation in Windows 10 Enterprise Evaluation x64 install.wim" `
 -FullName $TSName `
 -OrgName "Vagrant" `
 -HomePage "about:blank" `
 -Verbose

 ### Step 3: Creating the offline media
$offlineMediaRoot = "$Home\Desktop\Content\Deploy"
$OutISO = "Out_Win10_eva.iso"
New-Item -Path $offlineMediaRoot -ItemType directory
new-item -path "DS001:\Media" `
 -enable "True" `
 -Name "MEDIA001" `
 -Comments "" `
 -Root "$Home\Desktop" `
 -SelectionProfile "Everything" `
 -SupportX86 "false" `
 -SupportX64 "True" `
 -GenerateISO "True" `
 -ISOName $OutISO `
 -Verbose

new-PSDrive -Name "MEDIA001" `
 -PSProvider "MDTProvider" `
 -Root $offlineMediaRoot `
 -Description "Embedded media deployment share" `
 -Force -Verbose

### Step 4: Import the custom settings for TS (Happens Every time)
Copy-Item -Path "c:\bin\CustomSettings.ini" -Destination "$offlineMediaRoot\Control\CustomSettings.ini" -Force
Copy-Item -Path "c:\bin\Bootstrap.ini" -Destination "$offlineMediaRoot\Control\Bootstrap.ini" -Force

#burn the ISO
Write-Host "Producing the ISO..."
Update-MDTMedia -path "DS001:\Media\MEDIA001" -Verbose

#ship the ISO to synced folder on your work machine
Write-Host "Shipping the ISO to synced folder..."
Copy-Item -Path "$Home\Desktop\$OutISO" -Destination "C:\mdt\" -Force -Verbose  
Dismount-DiskImage $win10iso