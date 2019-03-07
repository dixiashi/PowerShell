
<#
$pfx = new-object System.Security.Cryptography.X509Certificates.X509Certificate2 
$certPath = read-host "Certificate Path"
$pfxPass = read-host "Password" -assecurestring
$pfx.import($certPath,$pfxPass,"Exportable,PersistKeySet") 
$store = new-object System.Security.Cryptography.X509Certificates.X509Store(
    [System.Security.Cryptography.X509Certificates.StoreName]::Root,
    "localmachine"
)
$store.open("MaxAllowed") 
$store.add($pfx) 
$store.close()
#>

$errortest = new-object Exception('fasdfa')
$test = $errortest.GetType().ToString() -eq 'System.Exception'
$test = $errortest -is [Exception]

write-host $test