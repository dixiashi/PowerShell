Param ([string]$versionNumber = $( Read-Host "Input the version number, please" ))

function Get-VersionValue {

    Param ([string]$filePath,[string]$regx)

    $filecontent = Get-Content $filePath
    $found = $filecontent -match $regx

    $version = ""
    $result = $found.GetValue(0) -match '\d+(\.\d+){1,8}'
    if ($result) {
        $version = $matches[0]
    }

    return $version;
}

function CompareAssemblyVersion
{
    Param ([string]$inputVersion, [string]$assemblyFilePath)

    $result = $false;
    $targetVersion = Get-VersionValue -filePath $assemblyFilePath -regx '^\[assembly: AssemblyVersion\(".*\"\)'
    write-host 'The AssemblyInfo.cs product version is: ' + $targetVersion

    if(CompareVersion -inputVersion $inputVersion -targetVersion $targetVersion)
    {
        $result = $true;
    }

    return $result;
}

function CompareMSIVersion
{
    Param ([string]$inputVersion, [string]$vdprojFilePath)

    $result = $false;
    $targetVersion = Get-VersionValue -filePath $vdprojFilePath -regx '\"ProductVersion\" = \"8:.*\"'

    write-host 'The MSI product version is: ' + $targetVersion
    if(CompareVersion -inputVersion $inputVersion -targetVersion $targetVersion)
    {
        $result = $true;
    }

    return $result;
}

function CompareVersion
{
    Param ([string]$inputVersion,[string]$targetVersion)

    $result = ($inputVersion -eq $targetVersion)
    if(!$result)
    {
        $result = ($inputVersion.TrimEnd(".0".ToCharArray()) -eq $targetVersion.TrimEnd(".0".ToCharArray()))
        if($result)
        {
            $message = [Environment]::NewLine
            $message += "Please pay attention, the the version number is not exact equal." + [Environment]::NewLine
            $message += "inputVersion:    " + $inputVersion + [Environment]::NewLine
            $message += "targetVersion:   " + $targetVersion + [Environment]::NewLine

            Write-Warning $message
        }
    }
    
    return $result
}

function MainProcess
{
    Param ([string]$versionNumber = $versionNumber)
    
    try
    {
        #region "Check the input value"
        #Check the input value
        if($versionNumber -notmatch '\d+(\.\d+){1,8}')
        {
            throw 'Invalid version number, the version number should be like 1.2.3'
        }
        #endregion

        #region "Get the AssemblyInfo.cs and *.vdproj file path"
        $assemblyFilePath = ''
        $vdprojFilePath = ''

        #Get the AssemblyInfo.cs and *.vdproj file path
        #Use the file under the trunk folder as the compared object.
        #***********************************************************************
        #For the 'trunk' folder, there is a fuzzy matching, not a exact mathing.
        #***********************************************************************
        Get-ChildItem -Path $PSScriptRoot -Recurse -Include *.vdproj, AssemblyInfo.cs | sort Directory | select Name, Directory | #where {$_.Directory -like "*trunk*"} | 
        Foreach-Object {
            if($_.Name -eq 'AssemblyInfo.cs')
            {
                $assemblyFilePath = [System.IO.Path]::Combine($_.Directory ,$_.Name)
            }
        
            if($_.Name -like '*.vdproj')
            {
                $vdprojFilePath = [System.IO.Path]::Combine($_.Directory ,$_.Name)
            }
        }

        if(![System.IO.File]::Exists($assemblyFilePath))
        {
            throw 'Can not find the "AssemblyInfo.cs" file.'
        }
        write-host 'The AssemblyInfo.cs file path is: ' + $assemblyFilePath


        if(![System.IO.File]::Exists($vdprojFilePath))
        {
            throw 'Can not find the "*.vdproj" file.'
        }
        write-host 'The *.vdproj file path is: ' + $vdprojFilePath
        #endregion

        #region "Compare the input version with assembly file version"
        if((CompareAssemblyVersion -inputVersion $versionNumber -assemblyFilePath $assemblyFilePath) -eq $false)
        {
            throw 'The input version is not same with the assembly version.'
        }
        #endregion
        
        #region "Compare the *.vdproj version with assembly file version"
        if((CompareMSIVersion -inputVersion $versionNumber -vdprojFilePath $vdprojFilePath) -eq $false)
        {
            throw 'The input version is not same with the MSI version.'
        }
        #endregion
    }
    catch
    {
        write-host 'There are some error occurred, please check the exception info.'
        write-error $_.Exception
    }

    write-host 'The input version are same with the assembly version and MSI version.'
}

MainProcess