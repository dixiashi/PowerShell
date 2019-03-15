
cls
#WholeProcess

$gitInfo = @(
@{
    SourceGit = "https://{A1 Repository URL}";
    TargetGit = "https://{B1 Repository URL}";
    Branch = "Dev";
}, @{
    SourceGit = "https://{A2 Repository URL}";
    TargetGit = "https://{B2 Repository URL}";
    Branch = "Dev";
}, @{
    SourceGit = "https://{A3 Repository URL}";
    TargetGit = "https://{B3 Repository URL}";
    Branch = "Dev";
})
$rootPath = $PSScriptRoot

$folderPath = Join-Path $PSScriptRoot ([guid]::NewGuid().ToString())
$sourceFolderPath = Join-Path $folderPath "Source"
$targetFolderPath = Join-Path $folderPath "Target"

$sourceGit = "https://{A Repository URL}"
$targetGit = "https://{B Repository URL}"
$branch = "Dev"

function Initialize()
{
    CreateItem -path $folderPath -itemType "Directory"
    CreateItem -path $sourceFolderPath -itemType "Directory"
    CreateItem -path $targetFolderPath -itemType "Directory"
}

function CreateItem()
{
    param(
        [string]$path,
        [string]$itemType
    )

    if(Test-Path $path)
    {
        if($itemType -eq "Directory")
        {
            Remove-Item -Path $path -Recurse
        }
        elseif($itemType -eq "File")
        {
            Remove-Item -Path $path -Force
        }
    }

    #Create
    New-Item -Path $path -ItemType $itemType
}

function CloneSourceCode()
{
    param(
        [string]$localPath,
        [string]$gitHttps,
        [string]$branch        
    )

    cd $localPath
    git clone $gitHttps

    $folderName = [System.Linq.Enumerable]::LastOrDefault($gitHttps.Split('/'))
    cd $folderName

    git checkout -b $branch 
    git branch --set-upstream-to=origin/$branch $branch
    git pull -s recursive -X theirs
}

function DeleteFolder()
{
    param(
        [string]$path
    )

    Remove-Item -Path $path -Recurse -Force
}

function CopyFiles()
{
    param(
        [string]$sourcePath,
        [string]$targetPath
    )

    Copy-Item -Path $sourcePath\* -Recurse $targetPath -Force
}

function PushSourceCode()
{
    param(
        [string]$path
    )
    
    cd $path

    git add .
    git commit -m "Merge the code"
    git push --set-upstream origin $branch
    git push
}


function WholeProcess()
{
    Initialize

    CloneSourceCode -branch $branch -gitHttps $sourceGit -localPath $sourceFolderPath

    CloneSourceCode -branch $branch -gitHttps $targetGit -localPath $targetFolderPath

    $sourceName = [System.Linq.Enumerable]::LastOrDefault($sourceGit.Split('/'))
    $sourceFullName = Join-Path $sourceFolderPath $sourceName
    DeleteFolder -path (Join-Path $sourceFullName ".git")

    $targetName = [System.Linq.Enumerable]::LastOrDefault($targetGit.Split('/'))
    $targetFullName = Join-Path $targetFolderPath $targetName
    CopyFiles -sourcePath $sourceFullName -targetPath $targetFullName

    PushSourceCode -path $targetFullName

    cd $rootPath

    #DeleteFolder -path $folderPath
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


$gitInfo | foreach {

    $sourceGit = $_.SourceGit
    $targetGit = $_.TargetGit
    $branch = $_.Branch

    $folderPath = Join-Path $PSScriptRoot ([guid]::NewGuid().ToString())
    $sourceFolderPath = Join-Path $folderPath "Source"
    $targetFolderPath = Join-Path $folderPath "Target"

    Write-Host $_.sourceGit

    WholeProcess
}
