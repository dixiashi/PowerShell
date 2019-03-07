<#param([string]$remoteComputerName, [string]$domainUser, [string]$userPassword)

$securePassword = ConvertTo-SecureString -String $userPassword -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $domainUser,$securePassword
$results = Invoke-Command -ComputerName $remoteComputerName -credential $cred -ScriptBlock {
#>
$remoteComputerName = "CTBTDT-3FGJPW1"
$results = Invoke-Command -ComputerName $remoteComputerName -ScriptBlock {
   try
   {
        $app = Get-WmiObject Win32_Product | where { $_.name -eq "POC.NexusUpload.Installer" }
        if($app -ne $null){
            write-host (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.ffffff") "Start to uninstall the POC.NexusUpload.Installer!"
            $app.Uninstall()
            write-host (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.ffffff") "End to uninstall the POC.NexusUpload.Installer!"

        }

        #msiexec /i "<filename.msi>" /q REINSTALL=ALL REINSTALLMODE=A
        write-host (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.ffffff") "Start to run the 'msiexec.exe POC.NexusUpload.Installer.msi' commander!"
        & cmd /c "msiexec.exe /i c:\download\LanSchool\POC.NexusUpload.Installer.msi" /qn ADVANCED_OPTIONS=1 CHANNEL=10
        write-host (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.ffffff") "End to run the 'msiexec.exe POC.NexusUpload.Installer.msi' commander!"
   }
   catch
   {
       return $_
   }
}

if($results -is [Exception]){
    throw $results    
} else {
    write-host (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.ffffff") $results
    write-host (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.ffffff") "Invoke-Command commander done!"
}
