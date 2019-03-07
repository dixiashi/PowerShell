#param([string]$remoteComputerName, [string]$domainUser, [string]$userPassword, [string]$instanllerName)



#Copy msi file to the target machine
$machineList = (
"**********12.chemtech.local",
"**********11.chemtech.local",
"**********07.chemtech.local",
"**********13.chemtech.local")
$machineList = ("**********.chemtech.local")

#\\ctbtvminf12\C$

$sourceFolder = "C:\\Qiang_WorkSpace\\Powershell\\Task739349\\Release\\*"
$instanllerName = "XOM.Informatics.FileCopyService"

foreach($machine in $machineList)
{
    $targetFolder = [System.IO.Path]::Combine("\\",$machine, "C$", "FileCopyServices")
    New-Item -ItemType Directory -Force -Path $targetFolder
    copy-item $sourceFolder $targetFolder\ -force -recurse -verbose 
    #$assemblyFilePath = [System.IO.Path]::Combine($_.Directory ,$_.Name)
    #remove-item $targetPath -force -recurse -verbose
    #copy-item c:\\src\\* c:\\dst -force -recurse -verbose
        
    $msiFilePath = $null
    Get-ChildItem -Path $targetFolder -Recurse -Include *.msi | select Name, Directory | 
    Foreach-Object {
        if($_.Name -like '*.msi')
        {
            $msiFilePath = [System.IO.Path]::Combine($_.Directory ,$_.Name)
        }
    }
    write-host $msiFilePath -ForegroundColor yellow

    if(![System.IO.File]::Exists($msiFilePath))
    {
        write-host 'Can not find the "*.msi" file.' -ForegroundColor red
    }
    #write-host $msiFilePath -ForegroundColor yellow
    <#
    $results = Invoke-Command -ComputerName $machine -ScriptBlock {
       try
       {
            $app = Get-WmiObject Win32_Product | where { $_.name -eq $instanllerName }
            if($app -ne $null){
                write-host (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.ffffff") $machine "Start to uninstall the $instanllerName!"
                $app.Uninstall()
                write-host (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.ffffff") $machine "End to uninstall the $instanllerName!"
            }

            write-host (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.ffffff") $machine "Start to run the 'msiexec.exe $msiFilePath' commander!"
            & cmd /c "msiexec.exe /i $msiFilePath" /qn ADVANCED_OPTIONS=1 CHANNEL=10
            write-host (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.ffffff") $machine "End to run the 'msiexec.exe $msiFilePath' commander!"
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
    #>
}