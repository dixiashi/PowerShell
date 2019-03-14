$source = @"
namespace UpdateService
{
    using System;
    using System.Net.Mail;

    public static class EmailHelper
    {

    }
}
"@

if (!("UpdateService.EmailHelper" -as [type])) {
    $referencedAssemblies = "${env:SystemDrive}\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.0\System.dll"
    Add-Type -TypeDefinition "$source" -ReferencedAssemblies $referencedAssemblies 
}
