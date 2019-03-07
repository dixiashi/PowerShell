#param([string]$remoteComputerName, [string]$domainUser, [string]$userPassword, [string]$instanllerName)

$name = "XOM.Informatics.FileCopyService"
$newFolder = [System.IO.Path]::Combine($PSScriptRoot, $name, "New")
$oldFolder = [System.IO.Path]::Combine($PSScriptRoot, $name, "Old")
$installFolder = [System.IO.Path]::Combine($PSScriptRoot, $name, "Install")
$configFolder = [System.IO.Path]::Combine($PSScriptRoot, $name, "Config")
$currentFolder = [System.IO.Path]::Combine($PSScriptRoot, $name, "Current")
$guid = "{CCE49312-DAF1-49F6-9801-7AEC3E16AEA2}"
[int]$errorType = 1


function UpgradeProcess()
{
    $msiFilePath = GetLatestFile -folderPath $installFolder
    return InstallProcess -inputValue $msiFilePath
}

function RevertProcess()
{
    $msiFilePath = GetLatestFile -folderPath $currentFolder
    return InstallProcess -inputValue $msiFilePath
}

function InstallProcess()
{
    Param (
        [string]$msiFilePath
    )

    if([System.IO.File]::Exists($msiFilePath))
    {
        Log -message "ERROR: {$msiFilePath} is not existed!" -type 1
        return $true
    }

    $result = $false
    try
    {
        #stop
        Stop-Service -Name $name
    
        #Uninstall
        Start-Process -FilePath "$env:windir\system32\msiexec.exe" -ArgumentList /x, $guid, /passive -Wait
    
        #Install
        Start-Process -FilePath "$env:windir\system32\msiexec.exe" -ArgumentList /i, $msiFilePath, /passive, ACCEPT_EULA=1 -Wait
    
        #Start
        Start-Service -Name $name

        $result = true
    }
    catch
    {
        write-error $_.Exception
        $result = false
    }

    return $result
}

function BackupInstallFile()
{
    try
    {
        copy-item $installFolder $currentFolder -force

        Remove-Item $oldFolder -force
        copy-item $currentFolder $oldFolder -force

        Remove-Item $currentFolder -force
        copy-item $newFolder $currentFolder -force

        Remove-Item $newFolder -force
    }
    catch
    {
        Log -message $_.Exception -type $errorType
    }
}

function RevertInstallFile()
{
    try
    {
        Remove-Item $newFolder -force

        Remove-Item $installFolder -force
        copy-item $currentFolder $installFolder -force
    }
    catch
    {
        Log -message $_.Exception -type $errorType
    }
}

function GetLatestFile()
{
    Param(
        [string]$folderPath
    )

    if(![System.IO.Directory]::Exists($folderPath))
    {
        return [string]::Empty
    }

    $msiFile =  gci $folderPath | sort LastWriteTime | select -last 1 

    if($msiFile -ne $null)
    {
        return $msiFile.Name
    }

    return [string]::Empty
}

function Log()
{
    param(
        [string]$message,
        [int]$type = 0
    )
    if($type -eq 0)
    {
        Write-Host $message
    } elseif($type -eq $errorType) {
        Write-Error $message
    } else {
        Write-Host $message
    }
}

function WholeProcess()
{
    if(!UpgradeProcess)
    {
        RevertProcess
        RevertInstallFile
    }else{
        BackupInstallFile
    }
}


Log "C:\ProgramData\ExxonMobil GCI\XOM.Informatics.FileCopyService\XOM.Informatics.FileCopyService\New11"