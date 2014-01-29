
Add-Type -AssemblyName System.Drawing

function New-ImageFromText{
    param(
        [Parameter(Mandatory=$true)]
        $text,

        $fontName = "Segoe UI",
        
        $fontSize = "11.0",

        $foregroundColor = @(0,0,0),

        $bkColor = @(240,240,240),

        $filePath
    )
    begin{
        Add-Type -AssemblyName System.Drawing
    }
    process{
        $img = New-Object System.Drawing.Bitmap 1,1
        $drawing = [System.Drawing.Graphics]::FromImage($img)
        $font = New-Object System.Drawing.Font($fontName, $fontSize)
        $textSize = $drawing.MeasureString($text, $font);

        $img.Dispose();
        $drawing.Dispose();

        $foreColorObj = [System.Drawing.Color]::FromArgb($foregroundColor[0], $foregroundColor[1], $foregroundColor[2])
        $backColorObj = [System.Drawing.Color]::FromArgb($bkColor[0], $bkColor[1], $bkColor[2])
        $brush = New-Object System.Drawing.SolidBrush($foreColorObj)

        $img = New-Object System.Drawing.Bitmap([int]($textSize.Width), [int]($textSize.Height))
        $drawing = [System.Drawing.Graphics]::FromImage($img)
        $drawing.Clear($backColorObj)
     
        $drawing.DrawString($text, $font, $brush, 0, 0)

        if($filePath){
            $img.Save($filePath)
        }
        
        $drawing.Dispose()
        $font.Dispose()
        $brush.Dispose()
        $drawing.Dispose()

        return $img
    }
}

function New-ImageFromTexTAsButton{
    param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true)]
        $text,

        $filePath,

        $fontName = "Segoe UI",
        
        $fontSize = "9.0",
        
        $bkColor = @(221,221,221),

        $paddingTop = 2,

        $paddingLeft = 11
    )
    begin{
        Add-Type -AssemblyName System.Drawing
    }
    process{
        # create the image with the correct background color
        $image = New-ImageFromText -text $text -bkColor $bkColor -fontName $fontName -fontSize $fontSize -filePath $filePath

        # We need to expand the image vertically and horizontally to add padding
        $newImage = New-Object System.Drawing.Bitmap(($image.Width + $paddingLeft*2),($image.Height + $paddingTop*2))

        $backColorObj = [System.Drawing.Color]::FromArgb($bkColor[0], $bkColor[1], $bkColor[2])
        $drawing = [System.Drawing.Graphics]::FromImage($newImage)
        $drawing.Clear($backColorObj)
        $drawing.Dispose()

        $graphics = ([System.Drawing.Graphics]::FromImage($newImage))
        $graphics.DrawImage($image, (New-Object System.Drawing.Point($paddingLeft,$paddingTop)))
        
        $image.Dispose()
        $graphics.Dispose()
        $image = $newImage

        $borderSize = 1
        $borderColor = [System.Drawing.Color]::FromArgb(172, 172, 172)
        $brush = New-Object System.Drawing.SolidBrush($borderColor)

        # http://stackoverflow.com/questions/14593121/how-can-i-create-a-border-frame-around-an-image
        $graphics = [System.Drawing.Graphics]::FromImage($image)
        $pen = (New-Object System.Drawing.Pen($brush, [float]$borderSize))
        $graphics.DrawRectangle( $pen, (New-Object System.Drawing.Rectangle(0,0,([int]$image.Width-$borderSize),([int]$image.Height-$borderSize))))
        
        $graphics.Dispose()
        $brush.Dispose()
        $pen.Dispose()

        return $image
    }
}

function Dispose-Object{
    param(
        [Parameter(ValueFromPipeline=$true)]
        $obj
    )
    process{
        if($obj){
            $obj.Dispose()
        }
    }
}

function Save-Image{
    param(
        [Parameter(
            ValueFromPipeline=$true
            )]
        $image,

        [switch]
        $fromclipboard,

        [switch]
        $toClipboard,
    
        $filePath
    )
    begin{
        Add-Type -AssemblyName System.Drawing
        Add-Type -AssemblyName System.Windows.Forms
    }
    process{
        if($fromclipboard){
            $image = ([System.Windows.Forms.Clipboard]::GetImage())
        }

        if($image -eq $null){
            '$image parameter must be provided, did you mean to pass -fromClipboard ?' | Write-Error
            return
        }

        if($filePath){
            $image.Save($filePath)
        }

        if($toClipboard -and $image){
            [System.Windows.Forms.Clipboard]::SetImage($image)
        }

        return $image
    }    
}

function Get-Image {
    param(
        $filePath,

        [switch]
        $fromClipboard
    )
    begin{
        Add-Type -AssemblyName System.Drawing
        Add-Type -AssemblyName System.Windows.Forms
    }
    process{
        $image = $null
        
        if($filePath){
            $image = ([System.Drawing.Image]::FromFile($filePath))
        }
        elseif($fromClipboard){
            $image = ([System.Windows.Forms.Clipboard]::GetImage())
        }
       
        return $image
    }
}

function Trim-Image {
    param(
        # this should be image type
        [Parameter(
            ValueFromPipeline=$true)]
        [System.Drawing.Image]
        $image,

        $trimLeft = 0,
        $trimRight = 0,
        $trimTop = 0,
        $trimBottom = 0,
        $trimAll = 0,
        [switch]
        $disposeOfImage,
        [switch]
        $fromClipboard,
        [switch]
        $toClipboard
    )
    begin{
        Add-Type -AssemblyName System.Drawing
        Add-Type -AssemblyName System.Windows.Forms
    }
    process {

        if($fromClipboard){
            $image = ([System.Windows.Forms.Clipboard]::GetImage())
        }

        if($image -eq $null){
            '$image parameter must be provided, did you mean to pass -fromClipboard ?' | Write-Error
            return
        }

        if($trimAll -and $trimAll -ne 0){
            $trimLeft = $trimRight = $trimTop = $trimBottom = $trimAll
        }

        # convert the image to a bitmap
        $bitmap = New-Object System.Drawing.Bitmap($image)

        $cropSize = New-Object System.Drawing.Size(
            ($bitmap.Width - $trimRight - $trimLeft),
            ($bitmap.Height - $trimBottom - $trimTop))

        $cropRect = New-Object System.Drawing.Rectangle(
            (New-Object System.Drawing.Point(
                ($trimLeft), ($trimTop))
            ),
            $cropSize)

        $newImage = $bitmap.Clone($cropRect, $bitmap.PixelFormat)


        $bitmap.Dispose()
        $image.Dispose()

        if($toClipboard){
            Save-image -image $newImage -toClipboard
        }

        if($disposeOfImage){
            $newImage.Dispose();
            return $null
        }

        return $newImage
    }
}

function Get-KnownFile{
    param(
        $relPath,

        $destPath,

        [switch]
        $toClipboardAsImage,

        $knownFilesRoot = ($global:knownFilesHome)
    )

    $fullPath = (Join-Path -Path $knownFilesRoot -ChildPath $relPath)

    if($destPath){
        Copy-Item -Path $fullPath -Destination $destPath
    }

    if($toClipboardAsImage){
        Get-KnownImageToClipboard -relPath $relPath
    }

    return $fullPath
}

function Get-KnownImageToClipboard{
    param(
        [Parameter(Mandatory=$true)]
        $relPath
    )
    begin{
        Add-Type -AssemblyName System.Drawing
        Add-Type -AssemblyName System.Windows.Forms
    }
    process{
        $fullPath = (Get-KnownFile -relPath $relPath)

        $image = ([System.Drawing.Image]::FromFile($fullPath))        
        [System.Windows.Forms.Clipboard]::SetImage($image) | Out-Null
        if($?){
            "Placed [{0}] on the clipboard" -f $relPath | Write-Host
        }
        else{
            "Unable to place image [{0}] on the clipboard" -f $relPath | Write-Error
        }

        $image.Dispose()

        return $fullPath
    }
}

function List-KnownFiles{
    process{
        return (Get-ChildItem $global:knownFilesHome -Recurse)
    }
}
# $global:knownFilesRoot = $global:knownFiles
function Configure-KnownFiles{
    param(
        $knownFilesRoot = ($global:knownFilesHome)
    )
    process{
        # this will setup IntelliSense and what not for known files

        if($global:knownFilesHome -ne $null){
            $completion_Process = {
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
 
                "knownFilesRoot: {0}" | Write-Host $knownFilesRoot

                #Get-ChildItem -Path "C:\Data\Dropbox\Personal\PcSettings\CommonFiles\" | ForEach-Object {
                Get-ChildItem -Path $global:knownFilesHome | ForEach-Object {
                    # generate a completing results for each
                    New-Object System.Management.Automation.CompletionResult $_.Name, $_.Name, 'ParameterValue', $_.Name
                }
            }

            if (-not $global:options) { $global:options = @{CustomArgumentCompleters = @{};NativeArgumentCompleters = @{}}}
            $global:options['CustomArgumentCompleters']['Get-KnownFile:relPath'] = $Completion_Process
            $function:tabexpansion2 = $function:tabexpansion2 -replace 'End\r\n{','End { if ($null -ne $options) { $options += $global:options} else {$options = $global:options}'
        }
        else{
            "You must set global:knownFilesHome to use Configure-KnownFiles" | Write-Error
        }
    }
}
function Get-FolderSize
{
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true)]
        $folder
    )
    begin{
        $fso = New-Object -comobject Scripting.FileSystemObject
    }
    process{
        if($folder){
            $dirInfo = (Get-Item $folder)

            $path = $dirInfo.fullname

            $folder = $fso.GetFolder($path)

            $size = $folder.size

            return ([PSCustomObject]@{'Name' = $path;'Size' = ($size / 1gb) })
        }       
    }
}
# New-ImageFromText "this is just a test" | Save-image -filePath 'C:\temp\img-fromps.bmp' | Dispose-Object
# Get-Image -filePath 'C:\temp\img.bmp' | Trim-Image -trimRight 20 -trimTop 10 -trimBottom 10 -trimLeft 10 | Save-Image -filePath 'c:\temp\img-fromps.bmp'

Configure-KnownFiles
Export-ModuleMember -function *
Export-ModuleMember -Variable *
Export-ModuleMember -Cmdlet *
