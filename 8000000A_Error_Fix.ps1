#Root caused:
#https://stackoverflow.com/questions/8648428/an-error-occurred-while-validating-hresult-8000000a

#--------------------------------------------------------------------------------------------------------------
# MSI Projects will not be built by default Visual Studio Build. In order to enable VS to build MSI projects we need to set a registry value for VS2103 and Vs2015
# This script will search the registry to see if there is an entry to enableoutofprocbuild. If found it updates the value to 0, else it creates the property newly
#--------------------------------------------------------------------------------------------------------------

cls
function EnableOutOfProcBuild()
{
    $name = "EnableOutOfProcBuild"
    $visualStudioPath = "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\VisualStudio"

    try
    {
        Get-ChildItem $visualStudioPath | where{
            # Iterate all *_Config* folder path
            if($_.Name.Contains("_Config"))
            {
                Write-Host "**************************************************************************"
                $msBuildPath = "Registry::" + $_.Name + "\MSBuild\"
                Write-Host Path:
                Write-Host $msBuildPath
        
                # Add or modify the value of EnableOutOfProcBuild
                $enable = (Get-ItemProperty $msBuildPath).EnableOutOfProcBuild
                if ($enable -eq $null)
                {
                    # EnableOutOfProcBuild property not found. Hence create a new property
                    New-ItemProperty -Path $msBuildPath -Name $name -Value 0 -PropertyType "DWord"
                    Write-Host "Added Key!!"
                }
                elseif($enable -ne 0)
                {
                    # EnableOutOfProcBuild property found. Hence update
                    Set-ItemProperty -Path $msBuildPath -Name $name -Type DWORD -Value 0
                    Write-Host "Updated Key!!"
                }

                Write-Host Property:
                Write-Host (Get-ItemProperty -Path $msBuildPath)
                Write-Host "Successfully Created / Updated EnableOutOfProcBuild property!!!"   
                Write-Host "**************************************************************************"
            }
        }
    }
    catch
    {
        write-error $_.Exception
    }
}
cls
EnableOutOfProcBuild
