
Add-Type -AssemblyName System.Drawing

function New-ImageFromText{
    param(
        [Parameter(Mandatory=$true)]
        $text,

        $fontName = "Segoe UI",
        
        $fontSize = "12.0",

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
        
        $brush.Dispose();
        $drawing.Dispose();

        return $img;
    }
}

function Dispose-Object{
    param(
        [Parameter(ValueFromPipeline=$true)]
        $obj
    )
    process{
        "in dispose" | Write-Host
        if($obj){
            $obj.Dispose()
        }
    }
}

function Save-Image{
    param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true
            )]
        $image,

        [Parameter(Mandatory=$true)]
        $filePath
    )
    process{
        $image.Save($filePath)
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
            Mandatory=$true,
            ValueFromPipeline=$true)]
        [System.Drawing.Image]
        $image,

        $trimLeft = 0,
        $trimRight = 0,
        $trimTop = 0,
        $trimBottom = 0
    )
    begin{
        Add-Type -AssemblyName System.Drawing
    }
    process {
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

        $newImage.Save('C:\temp\img-fromcloneps.bmp')
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

    return $fullPath
}

function Get-KnownImageToClipboard{
    param(
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
    }
}

function List-KnownFiles{
    process{
        return (Get-ChildItem $global:knownFilesHome -Recurse)
    }
}
# New-ImageFromText "this is just a test" | Save-image -filePath 'C:\temp\img-fromps.bmp' | Dispose-Object


Get-Image -filePath 'C:\temp\img.bmp' | Trim-Image -trimRight 20 -trimTop 10 -trimBottom 10 -trimLeft 10 | Save-Image -filePath 'c:\temp\img-fromps.bmp'


Export-ModuleMember -function *
Export-ModuleMember -Variable *
Export-ModuleMember -Cmdlet *
