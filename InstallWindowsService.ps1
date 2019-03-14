param([string]$remoteComputerName, [string]$domainUser, [string]$userPassword, [string]$msiFolder, [string]$serviceName)

function InstallWindowsService()
{
    param(
    [string]$remoteComputerName, 
    [string]$domainUser, 
    [string]$userPassword, 
    [string]$msiFolder, 
    [string]$serviceName)

    $securePassword = ConvertTo-SecureString -String $userPassword -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $domainUser,$securePassword
    $machine = $remoteComputerName

    $results = Invoke-Command -ComputerName $machine -Credential $cred -ScriptBlock {
    #$results = Invoke-Command -ComputerName $machine -ScriptBlock {
        Param (
            [string]$msiFolder, 
            [string]$serviceName
        )

        [int]$errorType = 1

        function UninstallWindowsService()
        {
            Param (
                [string]$msiFilePath
            )

            if(-not [System.IO.File]::Exists($msiFilePath))
            {
                Log -message "ERROR: {$msiFilePath} is not existed!" -type 1
                return
            }

            try
            {
                if (Get-Service $serviceName -ErrorAction SilentlyContinue)
                {
                    Log -message "Stop-Service -Name $serviceName"
                    Stop-Service -Name $serviceName
                }

                Log -message "Get-WmiObject -Class Win32_Product -Filter Name = '$serviceName'"
                $service = Get-WmiObject -Class Win32_Product -Filter "Name = '$serviceName'"

                Log -message $service
                if($service -eq $null)
                {
                    return
                }

                Log -message "$service.Uninstall()"
                $result = $service.Uninstall()
            }
            catch
            {
                write-error $_.Exception
                throw
            }
        }

        function InstallWindowsService()
        {
            Param (
                [string]$msiFilePath
            )

            if(-not [System.IO.File]::Exists($msiFilePath))
            {
                Log -message "ERROR: {$msiFilePath} is not existed!" -type 1
            }

            try
            {
                #Install
                Log -message "$env:windir\system32\msiexec.exe -ArgumentList /i ""$msiFilePath"" /quiet /l*v UpdateLog.txt"
                #start /wait msiexec.exe /i "$msiFilePath" /qn /quiet /l*v UpdateLog.txt
		        Start-Process "$env:windir\system32\msiexec.exe" -ArgumentList "/i ""$msiFilePath"" /quiet /l*v UpdateLog.txt" -Wait
            }
            catch
            {
                write-error $_.Exception
                throw
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
                return [System.IO.Path]::Combine($folderPath, $msiFile.Name)
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
                Write-Host $message >> $logPath
            } elseif($type -eq $errorType) {
                Write-Error $message >> $logPath
            } else {
                Write-Host $message >> $logPath
            }

            $message = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.ffffff ")+$message
            Write-Output $message >> $logPath
        }

        function WholeProcess()
        {
            try
            {
                Log -message "Start to WholeProcess"
                $msiFilePath = GetLatestFile -folderPath $msiFolder

                UninstallWindowsService -msiFilePath $msiFilePath

                InstallWindowsService -msiFilePath $msiFilePath
            }
            catch
            {
                $string_err = $_ | Out-String
                Log -message $string_err
                throw 
            }

            Log -message "End to WholeProcess"
        }

        function CheckServiceStatus()
        {
            try
            {
                $fcs = Get-Service -Name $serviceName
                if($fcs -eq $null)
                {
                    throw "Install failed, there is no $serviceName"
                }

                if($fcs.Status -ne "Running")
                {
                    throw ([string]::Format("Please check the service, it's notRunning, current status is {0}",$fcs.Status))
                }

                Log -message ([string]::Format("{0} is {1}", $serviceName, $fcs.Status))
            }
            catch
            {
                $string_err = $_ | Out-String
                Log -message $string_err
                throw 
            }


        }

        try
        {
            cls

            WholeProcess

            CheckServiceStatus
        }
        catch
        {
            Log -message ($_.Exception)
            throw $_.Exception
        }
    } -ArgumentList $msiFolder, $serviceName

    if($results -is [Exception]){
        throw $results    
    } else {
        write-host (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.ffffff") $results
        write-host (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.ffffff") "Invoke-Command commander done!"
    }
}

InstallWindowsService  -remoteComputerName $remoteComputerName -domainUser $domainUser -userPassword $userPassword -msiFolder $msiFolder -serviceName $serviceName
