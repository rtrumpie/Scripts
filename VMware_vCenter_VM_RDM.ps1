#Prompt for username and password (username@domain)
$Cred = Get-Credential -Message "Please insert FQN credentials"
$Username = $Cred.UserName
$Password = $Cred.GetNetworkCredential().Password

#vCenter
$vcenter = "vCenter HERE"

#Surpress SSL Error
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

#Load VMware Module
Import-module VMware.VimAutomation.Core

Connect-VIServer $vcenter -User $Username -Password $Password

$report = @()
$vms = Get-VM | Get-View
foreach($vm in $vms){
  foreach($dev in $vm.Config.Hardware.Device){
    if(($dev.gettype()).Name -eq "VirtualDisk"){
       if(($dev.Backing.CompatibilityMode -eq "physicalMode") -or 
          ($dev.Backing.CompatibilityMode -eq "virtualMode")){
         $row = "" | select VMName, HDDeviceName, HDFileName, HDMode
          $row.VMName = $vm.Name
         $row.HDDeviceName = $dev.Backing.DeviceName
         $row.HDFileName = $dev.Backing.FileName
         $row.HDMode = $dev.Backing.CompatibilityMode
         $report += $row
       }
     }
  }
}
$report