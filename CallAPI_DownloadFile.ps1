
function SendRequest()
{
    param([string]$url, [string]$method, [object]$postData)
    write-host "************************************************************************************************************************"
    $body = $postData | ConvertTo-Json
    $bodyString = $null
    if($body -ne $null)
    {
        $bodyString = (ConvertFrom-Json $body)
    }

    write-host "Request         ULR: "$url
    write-host "Request      Method: "$method
    write-host "Request    PostData: "$bodyString
    write-host "Request    PostData: "$body
    try
    {
        $user = '********'
        $pass = '********'
        $pair = "$($user):$($pass)"
        $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
        $basicAuthValue = "Basic $encodedCreds"
        $Headers = @{
            Authorization = $basicAuthValue
        }

        $response = Invoke-RestMethod -Uri $url -Method $method -Body $body -ContentType "application/json" -Headers $Headers
        $jsonObject = $response | ConvertTo-Json
        write-host "Response     Result: " $response
    }
    catch
    {
        $string_err = $_ | Out-String
        throw $string_err
    }
    finally
    {
        write-host "************************************************************************************************************************"
    }
}

function DownloadRequest()
{
    param([string]$url)
    write-host "************************************************************************************************************************"
    write-host "Download        ULR: "$url
    try
    {
        $user = '********'
        $pass = '********'
        $pair = "$($user):$($pass)"
        $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
        $basicAuthValue = "Basic $encodedCreds"
        $Headers = @{
            Authorization = $basicAuthValue
        }
        
        $response = Invoke-WebRequest -uri $url -Method GET -Headers $headers
        $fileName = $response.Headers["Content-Disposition"].Split('"')[1]
        $downloadFilePath = Join-path $PSScriptRoot $fileName;
        if([System.IO.File]::Exists($downloadFilePath))
        {
            Write-Host "Delete Existed File: "$downloadFilePath
            Remove-Item $downloadFilePath
        }

        if($response.content -is [System.Byte[]])
        {
            [System.IO.File]::WriteAllBytes("$downloadFilePath", $response.content)
        } else {
            [System.IO.File]::WriteAllText("$downloadFilePath", $response.content)
        }
        write-host "Download   FilePath: "$downloadFilePath
        write-host "Response    Headers: "$response.Headers

        #unzip
        if($downloadFilePath.EndsWith(".zip"))
        {
            $zipFolder = Join-path $PSScriptRoot $fileName.TrimEnd(".zip")
            if([System.IO.Directory]::Exists($zipFolder))
            {
                write-host "Del ZipFolder Files: "$zipFolder
                Get-ChildItem $zipFolder 
                Remove-Item $zipFolder\* -Force
            } else {
                [System.IO.Directory]::CreateDirectory($zipFolder)
            }

            Add-Type -assembly 'System.IO.compression.filesystem'
            [io.compression.zipfile]::ExtractToDirectory($downloadFilePath, $zipFolder)
            write-host "Unzip    FolderPath: "$zipFolder
        }

    }
    catch
    {
        $string_err = $_ | Out-String
        throw $string_err
    }
    finally
    {
        write-host "************************************************************************************************************************"
    }
}

function RegisterNewSoftVersion()
{
    $url = "http://198.43.246.82:8080/iSoftwareManager/rest/software/add"
    $method = "Put"
    $postData = @{
        buildComputer = 0;
        deploymentNotesID = 0;
        deployPackageID = 0;
        releaseNotesID = 0;
        softwareID = 323;
        versionStatus = 3;
        testPlanID = 0;
        testPlanStatus = 0;
        status = 0;
        version = "1.0.1.9";
        ITSCase = 0;
        licenseAttachmentID = 0;
        unlimitedLicenses = $false;
        numberOfLicenses = 0;
        softwareName = "ISMTest3";
        classification = 11;
        doEmail = $false
    }

    SendRequest $url $method $postData
}

function UpdateSoftVersion()
{
    try
    {
        $url = "http://198.43.246.82:8080/iSoftwareManager/rest/software/version/update"
        $method = "POST"
        $postData = @{
            id = 364;
            buildComputer = 0;
            deploymentNotesID = 0;
            deployPackageID = 0;
            releaseNotesID = 0;
            softwareID = 323;
            versionStatus = 3;
            testPlanID = 0;
            testPlanStatus = 0;
            status = 0;
            version = "1.0.1.5";
            ITSCase = 0;
            licenseAttachmentID = 0;
            unlimitedLicenses = $false;
            numberOfLicenses = 0;
            softwareName = "ISMTest3";
            classification = 11;
            doEmail = $false
        }

        SendRequest $url $method $postData
    }
    catch
    {
        $string_err = $_ | Out-String
        throw $string_err
    }
}

function GetDeployment()
{
    $url = "http://198.43.246.82:8080/iSoftwareManager/rest/deployment/detail?deploymentID=1096"
    $method = "Get"
    $postData = $null

    SendRequest $url $method $postData
}

function AddDeployment()
{
    $url = "http://198.43.246.82:8080/iSoftwareManager/rest/deployment/add"
    $method = "POST"
    $postData = @{
        project = "Informatics-HWSWInventory";
        softwareVersionID = 1380;
        softwareID = 323;
        computerID = 663;
        #deployProcedureID = 10126994;
        deployRiskCategory = 1;
        deployRiskLevel = 3;
        itsCase = 608336;
        #softwareClassification = 11;
        #status = 0;
        versionStatus = 8;
        computerRole = 0;
        deployStaff = "qihao01";
        deployURL = "http://nexus.na.xom.com:8081/repository/chem-informatics-raw/XOM.Informatics.FileCopyService/XOM.Informatics.FileCopyService_Setup_V1_1_1.msi";
        deployNotes = "This is a test about add deployment";
        sites = @('Shanghai');
        lastVerifiedBy = "asong01";
        deploymentDate = "28-Jun-2019";
        lastVerifiedOn = "28-Jan-2019";
        licenseKey = "";
        computerName = "CTBTTESTVM01";
        softwareName = "ISMTest3";
        version = "1.0.1.8";
        iTSSystem = "TFS"
    }

    SendRequest $url $method $postData
}

function UpdateDeployment()
{
    $url = "http://198.43.246.82:8080/iSoftwareManager/rest/deployment/update"
    $method = "POST"
    $postData = @{
        id = 1096;
        project = "Informatics-HWSWInventory";
        softwareVersionID = 1380;
        softwareID = 323;
        computerID = 663;
        #deployProcedureID = 10126994;
        deployRiskCategory = 1;
        deployRiskLevel = 3;
        itsCase = 608336;
        #softwareClassification = 11;
        #status = 0;
        versionStatus = 8;
        computerRole = 0;
        deployStaff = "qihao01";
        deployURL = "http://nexus.na.xom.com:8081/repository/chem-informatics-raw/XOM.Informatics.FileCopyService/XOM.Informatics.FileCopyService_Setup_V1_1_1.msi";
        deployNotes = "This is a test about add deployment";
        sites = @('Shanghai');
        lastVerifiedBy = "asong01";
        deploymentDate = "28-Jun-2019";
        lastVerifiedOn = "28-Jan-2019";
        licenseKey = "";
        computerName = "CTBTTESTVM01";
        softwareName = "ISMTest3";
        version = "1.0.1.8";
        iTSSystem = "TFS"
    }

    SendRequest $url $method $postData
}

function DownloadConfig()
{
    $url = "http://198.43.246.82:8080/iSoftwareManager/rest/file/downloadFile?fileIds=10132273"
    DownloadRequest $url
}

function DownloadZip()
{
    $url = "http://198.43.246.82:8080/iSoftwareManager/rest/file/downloadFile?fileIds=10065346,10123706"
    DownloadRequest $url
}

cls
#RegisterNewSoftVersion
#UpdateSoftVersion
#GetDeployment
#AddDeployment
#UpdateDeployment
#DownloadConfig
#DownloadZip

Write-Host "Hello World"