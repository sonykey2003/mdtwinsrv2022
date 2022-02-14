  #Setting the parameters
  $MDTShareName = "DS001"
  $MDTSharePath = $MDTShareName + ":\"
  $MDTShareRoot = "c:\MDTDeploymentShare$"
  $Syncedfolder = "c:\iso\"
  $ISOName = "win10_ent.iso"
  $TemplatePath = "c:\iso\bin\"
  $OfflineMediaRoot = "$HOME\Desktop"
  $OfflineConfigRoot = "$HOME\Desktop\Content\Deploy"
  $OfflineMediaName = "MEDIA001"
  $OutISO = "Out_Win10_eva.iso"
  
  Write-Host "Configuring MDT..."
  
  Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
  New-PSDrive -Name $MDTShareName -PSProvider MDTProvider -Root $MDTShareRoot -ErrorAction SilentlyContinue
  
  ### Step 1: WIM Importation & Mounting
  $WIMName = (Get-ChildItem ($MDTSharePath+'operating systems')).name
  
  if ($null -eq $WIMName){
      #mounting the OS ISO for WIM extraction
      Write-Host "Mounting the ISO for WIM extraction..."
      Mount-DiskImage -ImagePath "$Syncedfolder$isoname"
      #Get-DiskImage -DevicePath \\.\CDROM0 | Get-Volume
  
      #importing OS from WIM or DVD
      Write-Host "Importing WIM..."
      import-mdtoperatingsystem -path ($MDTSharePath + 'Operating Systems') -SourceFile "D:\sources\install.wim" -DestinationFolder "win10" -Verbose
      $WIMName = (Get-ChildItem ($MDTSharePath+'operating systems')).name
      Dismount-DiskImage -DevicePath \\.\CDROM0
  
  }
  else{
      Write-Host "WIM existing, Skipping WIM Importation & Mounting..."
  }
  
  
  ### Step 2: Force importing the latest version of task sequence tamplate
  $TSName = "test"
  Remove-Item -Force ($MDTSharePath + 'Task Sequences\' + $TSName) -ErrorAction SilentlyContinue -Verbose
  
  Write-Host "Importing customised Task Sequence..."
  import-mdttasksequence -path ($MDTSharePath + 'Task Sequences') `
   -Name $TSName `
   -Template ($TemplatePath+'ts.xml')`
   -ID "1" -Version "1.0" `
   -OperatingSystemPath ($MDTSharePath+"Operating Systems\$WIMName")`
   -FullName "win10_eva" -OrgName "Vagrant"`
   -HomePage "about:blank"`
   -AdminPassword "vagrant"`
   -ErrorAction SilentlyContinue -Verbose
  
   ### Step 3: Creating the offline media
  #creating the media
  if ($null -eq (Get-ChildItem ($MDTSharePath+'Media'))){
     Write-Host "Creating the offline media..."
     new-item -path ($MDTSharePath+'Media') `
      -enable "True" -Name $OfflineMediaName `
      -Comments "" -Root $offlineMediaRoot `
      -SelectionProfile "Everything" `
      -SupportX86 "False" -SupportX64 "True" `
      -GenerateISO "True" -ISOName $OutISO -Verbose
  }
  else{
     Write-Host "skipping, Media exists!"
  }
 
  new-PSDrive -Name $OfflineMediaName `
  -PSProvider "MDTProvider" `
  -Root $OfflineConfigRoot `
  -Description "Embedded media deployment share" `
  -Force -Verbose -ErrorAction SilentlyContinue
  
  
  ### Step 4: Import the custom settings for TS (Happens Every time)
  Write-Host "Importing customised settings of offline media..."
  Copy-Item -Path ($TemplatePath+'CustomSettings.ini') -Destination "$OfflineConfigRoot\Control\CustomSettings.ini" -Force
  Copy-Item -Path ($TemplatePath+'Bootstrap.ini') -Destination "$OfflineConfigRoot\Control\Bootstrap.ini" -Force
  
  ### Step 5: Produce the ISO
  #update the deployment share from the previous step
  Update-MDTDeploymentShare -Path $MDTSharePath
  
  #burn the ISO
  Write-Host "Producing the ISO..."
  Update-MDTMedia -path ($MDTSharePath+"Media\$OfflineMediaName") -Verbose
  
  #ship the ISO to synced folder on your work machine
  Write-Host "Shipping the ISO to synced folder..."
  Copy-Item -Path ($offlineMediaRoot +"\" + $OutISO) -Destination $Syncedfolder -Force -Verbose 
   
 