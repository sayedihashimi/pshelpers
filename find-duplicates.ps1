<#
.SYNOPSIS
This will find duplicate files from one folder to another.
#>
[cmdletbinding()]
param(
    [Parameter(Mandatory=$true)]
    $leftFolder,
    [Parameter(Mandatory=$true)]
    $rightFolder)

function Find-Duplicates{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)]
        $leftFolder,
        [Parameter(Mandatory=$true)]
        $rightFolder)
    process{
        # compute the hash for every file under $rightFolder and place it in an array
        $rightFiles = (Get-ChildItem $rightFolder -Recurse | Get-FileHash)

        $duplicateFiles = @()

        Get-ChildItem $leftFolder -Recurse | 
            Get-FileHash | ForEach-Object {
                $leftItem = $_
                # see if this has is in the list above
                $foundFiles = ($rightFiles | Where-Object { $leftItem.Hash -eq $_.Hash })
                if($foundFiles){
                    foreach($dup in $foundFiles){
                        $dupEntry = @{}
                        $dupEntry.SourceFile = $_.Path
                        $dupEntry.DuplicateFile = $dup.Path
                        $dupEntry.Hash = $_.Hash

                        $duplicateFiles+=$dupEntry
                    }
                }
            }
        
        $duplicateFiles
    }
}

Find-Duplicates -leftFolder $leftFolder -rightFolder $rightFolder