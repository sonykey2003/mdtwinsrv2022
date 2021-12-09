#create a tmp work folder
mkdir c:\tmp -force
cd c:\tmp

#Enable MDT feature
Install-WindowsFeature WDS,WDS-Deployment,WDS-AdminPack

#Install ADK Deployment Tools feature
curl -Uri "https://go.microsoft.com/fwlink/?linkid=2165884" -OutFile C:\tmp\adk.exe
.\adk.exe /features OptionId.DeploymentTools /quiet
sleep 60

#Install the windows PE mgmt feature
curl -Uri "https://go.microsoft.com/fwlink/?linkid=2087112" -OutFile C:\tmp\pe.exe
.\pe.exe /features + /q  
sleep 20

#Install MDT Toolkit feature
curl -Uri "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi" -outfile c:\tmp\mdt64.msi
.\mdt64.msi /quiet
sleep 60

Add-PSSnapin -Name Microsoft.BDD.PSSnapIn | Get-PSSnapin |? {$_.name -like "Microsoft.BDD.PSSnapIn"}

#Create a MDT share
New-Item "C:\MDTDeploymentShare$" -Type directory  
([wmiclass]"win32_share").Create("C:\MDTDeploymentShare$", "MDTDeploymentShare$",0)  
New-PSDrive -Name "MDT001" -PSProvider "MDTProvider" -Root "C:\MDTDeploymentShare$" -Description "MDT Deployment Share Created with Cmdlets" -NetworkPath "\\$hostname\MDTDeploymentShare$" -Verbose  
$NewDS=Get-PSDrive "MDT001"  
Add-MDTPersistentDrive  -Name "MDT001" -InputObject $NewDS -Verbose 