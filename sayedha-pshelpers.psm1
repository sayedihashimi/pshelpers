[cmdletbinding()]
param()

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

$global:imghelpersettings = New-Object PSObject -Property @{
    DefaultFontName = 'Segoe UI'
    DefaultFontStyle = 'Regular'
    DefaultFontSize = '9.0'

    DefaultForegroundColor = @(255,0,0,0)
    DefaultBkColor = @(255,240,240,240)

    ColorLink = @(255,0,102,204)
    ColorGrey = @(255,240,240,240)
    ColorWhite = @(255,255,255,255)
}

$global:vscolors = @{
    "White" = @(255,255,255,255)
    "Black" = @(255,0,0,0)
    "GreyBkgrnd" = @(255,240,240,240)
    "Link" = @(255,0,102,204)
    "ActiveTab" = @(255,255,242,157)
}


# http://mnaoumov.wordpress.com/2013/08/21/powershell-resolve-path-safe/
function Resolve-FullPath{
    [cmdletbinding()]
    param
    (
        [Parameter(
            Mandatory=$true,
            Position=0,
            ValueFromPipeline=$true)]
        [string] $path
    )
     
    $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
}

function Search-DirectoryForString{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$text,

        [Parameter(Position=1)]
        [System.IO.DirectoryInfo[]]$path = '.\',

        [Parameter(Position=2)]
        [string]$filter,

        [Parameter(Position=3)]
        [string[]]$exclude,

        [Parameter(Position=4)]
        [bool]$simpleMatch = $true,

        [Parameter(Position=5)]
        [bool]$recurse = $true
    )
    process{
        $getitemparams = @{
            Path = $path
            Filter = $filter
            Exclude = [string[]]$exclude
        }
        if($recurse){
            $getitemparams.Add('Recurse',$true)
        }

        $selectstrparams = @{
            Pattern = $text
        }
        if($simpleMatch){
            $selectstrparams.Add('SimpleMatch',$true)
        }

        Get-ChildItem @getitemparams | Select-String @selectstrparams
    }
}

function New-TextImageGreyBackground {
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            Position=0)]
        $text,
        $fontName = $global:imghelpersettings.DefaultFontName,
        
        $fontSize = $global:imghelpersettings.DefaultFontSize,        
        
        [ValidateSet('Regular','Bold','Underline','Italic','Strikeout')]
        $fontStyle = 'Regular',
        
        $foregroundColor = $global:imghelpersettings.DefaultForegroundColor,
        
        $bkColor = $global:imghelpersettings.ColorGrey,
        
        $filePath,
        
        $saveToClipboard = $true
    )
    begin{
        Add-Type -AssemblyName System.Drawing
        Add-Type -AssemblyName System.Windows.Forms
    }
    process{
        New-ImageFromText -text $text -fontName $fontName -fontSize $fontSize -fontStyle $fontStyle -foregroundColor $foregroundColor -bkColor $bkColor -filePath $filePath -saveToClipboard $saveToClipboard
    }
}

function New-TextImageAsLink{
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            Position=0)]
        $text,
        $fontName = $global:imghelpersettings.DefaultFontName,
        
        $fontSize = $global:imghelpersettings.DefaultFontSize,        
        
        [ValidateSet('Regular','Bold','Underline','Italic','Strikeout')]
        $fontStyle = 'Underline',
        
        $foregroundColor = $global:imghelpersettings.ColorLink,
        
        $bkColor = $global:imghelpersettings.ColorGrey,
        
        $filePath,
        
        $saveToClipboard = $true
    )
    process{
        New-ImageFromText -text $text -fontName $fontName -fontSize $fontSize -fontStyle $fontStyle -foregroundColor $foregroundColor -bkColor $bkColor -filePath $filePath -saveToClipboard $saveToClipboard
    }
}

function New-TextImageWhitebackground{
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            Position=0)]
        $text,
        $fontName = $global:imghelpersettings.DefaultFontName,

        $fontSize = $global:imghelpersettings.DefaultFontSize,        

        [ValidateSet('Regular','Bold','Underline','Italic','Strikeout')]
        $fontStyle = 'Regular',

        $foregroundColor = $global:imghelpersettings.DefaultForegroundColor,

        $bkColor = @(255,255,255,255),

        $filePath,

        $saveToClipboard = $true
    )
    process{
        New-ImageFromText -text $text -fontName $fontName -fontSize $fontSize -fontStyle $fontStyle -foregroundColor $foregroundColor -bkColor $bkColor -filePath $filePath -saveToClipboard $saveToClipboard
    }
}

function New-ImageFromText {
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            Position=0)]
        $text,

        $fontName = $global:imghelpersettings.DefaultFontName,
        
        $fontSize = $global:imghelpersettings.DefaultFontSize,        
        
        [ValidateSet('Regular','Bold','Underline','Italic','Strikeout')]
        $fontStyle = $global:imghelpersettings.DefaultFontStyle,
        
        $foregroundColor = $global:imghelpersettings.DefaultForegroundColor,
        
        $bkColor = $global:imghelpersettings.DefaultBkColor,
        
        $filePath,
        
        $saveToClipboard = $true
    )
    begin{
        Add-Type -AssemblyName System.Drawing
    }
    process{
        $fontStyleObj = [Enum]::Parse('System.Drawing.FontStyle',$fontStyle)

        $img = New-Object System.Drawing.Bitmap 1,1
        
        $drawing = [System.Drawing.Graphics]::FromImage($img)       
        $drawing.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

        $font = New-Object System.Drawing.Font($fontName, $fontSize,$fontStyleObj)
        
        $textSize = $drawing.MeasureString($text, $font);

        $img.Dispose();
        $drawing.Dispose();

        $foreColorObj = [System.Drawing.Color]::FromArgb($foregroundColor[0], $foregroundColor[1], $foregroundColor[2], $foregroundColor[3])
        $backColorObj = [System.Drawing.Color]::FromArgb($bkColor[0], $bkColor[1], $bkColor[2], $bkColor[3])
        $brush = New-Object System.Drawing.SolidBrush($foreColorObj)

        $img = New-Object System.Drawing.Bitmap([int]($textSize.Width), [int]($textSize.Height))
        $drawing = [System.Drawing.Graphics]::FromImage($img)
        $drawing.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
        $drawing.Clear($backColorObj)
     
        $drawing.DrawString($text, $font, $brush, 0, 0)

        if($filePath){
            $img.Save((Resolve-FullPath $filePath))
        }
        
        $drawing.Dispose()
        $font.Dispose()
        $brush.Dispose()
        $drawing.Dispose()

        if($saveToClipboard){
            [System.Windows.Forms.Clipboard]::SetImage($img)
        }

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
        
        $bkColor = @(255,221,221,221),

        $paddingTop = 2,

        $paddingLeft = 11,
        $saveToClipboard = $true
    )
    begin{
        Add-Type -AssemblyName System.Drawing
    }
    process{
        # create the image with the correct background color
        $image = New-ImageFromText -text $text -bkColor $bkColor -fontName $fontName -fontSize $fontSize -filePath $filePath

        # We need to expand the image vertically and horizontally to add padding
        $newImage = New-Object System.Drawing.Bitmap(($image.Width + $paddingLeft*2),($image.Height + $paddingTop*2))
        
        $backColorObj = [System.Drawing.Color]::FromArgb($bkColor[0], $bkColor[1], $bkColor[2],$bkColor[3])
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
        
        if($saveToClipboard){
            [System.Windows.Forms.Clipboard]::SetImage($image)
        }

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
            $image.Save((Resolve-FullPath $filePath))
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
            $image = ([System.Drawing.Image]::FromFile((Resolve-FullPath $filePath)))
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
            "Placed [{0}] on the clipboard" -f $relPath | Write-Output
        }
        else{
            "Unable to place image [{0}] on the clipboard" -f $relPath | Write-Error
        }

        $image.Dispose()

        return $fullPath
    }
}

function Set-Owner{
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true)]
        $item,

        [switch]
        $recursive
    )
    begin{}
    process{
        # http://stackoverflow.com/questions/8216510/how-do-i-change-the-owner-of-a-folder-with-powershell-when-get-acl-returns-acce
        # takeown /F "C:\SomeFolder" /R /D Y

        foreach($itemToSet in $item){
            $itemObj = Get-Item $itemToSet

            $cmdArgs = @()
            $cmdArgs += '/F'
            $cmdArgs += ($itemObj.FullName)
            if($recursive){
                $cmdArgs += '/R'

                # these two need to be sequential
                $cmdArgs += '/D'
                $cmdArgs += 'Y'
            }

            'executing command:
                takeown {0}' -f ($cmdArgs -join ' ') | Write-Output

            & takeown $cmdArgs
        }
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
 
                "knownFilesRoot: {0}" | Write-Output $knownFilesRoot

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

#Configure-KnownFiles
Export-ModuleMember -function *
Export-ModuleMember -Variable *
Export-ModuleMember -Cmdlet *
