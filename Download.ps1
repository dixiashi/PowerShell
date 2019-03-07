cls

#Get the mp3 duration time
function GetDurationSecond()
{
    param(
    [string]$fullPath=$(throw "Parameter missing: -fullPath fullPath")
    )

    $source=@"
        using WMPLib;
        public static class MediaHelper
        {
            public static string GetDuration(string fileFullPath)
            {
                string result = string.Empty;
                try
                {
                    WindowsMediaPlayerClass wmp = new WindowsMediaPlayerClass();
                    IWMPMedia media = wmp.newMedia(fileFullPath);
                    result = media.durationString;
                }
                catch 
                {
                    //Eat the exception
                }

                return result;
            }
        }
"@

    #How to get the Interop.WMPLib.dll?
    #1. Open the vs and create or reopen a exit project
    #2. Add reference -> C:\Windows\System32\wmp.dll
    #3. In the debug folder, will generated the Interop.WMPLib.dll
    #https://blog.csdn.net/ennaymonkey/article/details/80522002
    $ref=@("D:\MyProject\ReadData\ReadData\obj\Debug\Interop.WMPLib.dll")
    $ref | foreach {
        Add-Type -Path $_
    }

    #if((-not [MediaHelper]) -and -not ([MediaHelper] -is [System.Object]))
    #{
    #    Add-Type -TypeDefinition $source -ReferencedAssemblies $ref
    #}
    
    $result = [MediaHelper]::GetDuration($fullPath)
    #$result = "01:01:03"
    $splits = $result.Split(':')
    $len = $splits.Length
    $sum = 0;
    $factor = 1;
    for($i=$len-1; 0 -le $i; $i--)
    {
        $sum = $sum + [convert]::ToInt32($splits[$i]) * $factor;
        $factor = $factor * 60
    }

    return $sum
}


#并行工作流
workflow Test-workflow
{
    param([int]$num)
    foreach -parallel ($item in 1..$num)
    {
        $url = "http://down010702.tingclass.net/lesson/shi0529/10000/10173/$item.mp3"
        $fileName = "$item.mp3"
        $folder = "D:\MyFile\EngLish\Lucy"
        $fullPath = Join-Path $folder $fileName
        $timeOut = 30*60
        if(-not [system.io.file]::Exists($fullPath))
        {
            Invoke-WebRequest $url -OutFile $fullPath -TimeoutSec $timeOut
        }
    }

}

function RemoveNotReadyFile()
{
    $loop = 110
    foreach($item in 1..$loop)
    {
        $fileName = "$item.mp3"
        $folder = "D:\MyFile\EngLish\Lucy"
        $fullPath = Join-Path $folder $fileName

        try
        {
            if([System.IO.File]::Exists($fullPath))
            {
                $duration = GetDurationSecond -fullPath $fullPath

                if($duration -lt 60)
                {
                    Write-Host $duration
                    Write-Host $fullPath
                    Remove-Item $fullPath
                    Write-Host "*****************************************"
                }
            }
        }
        catch 
        {
            Write-Host $_.Exception.Message
            #Remove-Item $fullPath
        }
        finally
        {
            #Write-Host $fullPath
        }
    }
}

function WholeProcess()
{
    $loop = 110
    Test-workflow -num $loop
    Write-Host "--------------------------------------------------"
    RemoveNotReadyFile
}

WholeProcess

#RemoveNotReadyFile
