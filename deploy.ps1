param(
    $deployRoot = (join-path -path $global:dropBoxHome -ChildPath 'Personal\PcSettings\Powershell\CustomModules')
)

function Get-ScriptDirectory
{
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    Split-Path $Invocation.MyCommand.Path
}

$scriptDir = ((Get-ScriptDirectory) + "\")

function Deploy-Helpers(){
    # see if the folder is defined or not
    if(Test-Path $deployRoot){
        # copy the .psm1 files to that folder
        $filesToCopy = (Get-ChildItem $scriptDir -Recurse -Exclude @("deploy.ps1","test.ps1"))
        Push-Location
        Set-Location $scriptDir
        foreach($file in $filesToCopy){
            # compute relative path
            $relPath = Resolve-Path -Path ($file.FullName) -Relative
            # get rid of ".\"
            $relPath = $relPath.TrimStart(".\")
            $destPath = Join-Path -Path $deployRoot -ChildPath $relPath

            Copy-Item -Path $file.FullName -Destination $destPath

            $foo = $destPath
        }
        Pop-Location
    }
    else{
        "Deploy root not found at [{0}]" -f $deployRoot | Write-Error
    }
}

Deploy-Helpers