
<#
add-watermark-to-image.ps1
batch watermark image and remove metadata 
Nov 27, 2022
V1.002
written by Carl
#>

Param(
  [parameter(Mandatory=$true, HelpMessage="Please enter the path to the images that will be watermarked")]
  [ValidateScript({Test-Path -Path $_ -PathType ‘Container’})]
  [String]
  $Source, #path to folder with images that will be watermarked

  [parameter(Mandatory=$false)] 
  [ValidateScript({
    $valid = $true
    foreach-object {
      if ($_.gettype().Name -ne 'String' ) {
        $valid = $false
      }
    $valid
    }}
  )]
  $ImageFileExtensions = ("jpg", "jpeg", "png"), #watermark only files with these extensions

  [parameter(Mandatory=$true, HelpMessage="Please enter the path of the watermark image file")]
  [ValidateScript({Test-Path -Path $_ -PathType ‘Leaf’})]
  [String]
  $WatermarkImage, #watermark image file
  
  [parameter(Mandatory=$false, HelpMessage="Please enter opacity that the watermark will have, valid range is 0% - 100%")]
  [ValidateRange(0,100)]
  [single]
  $Opacity = 100, #opacity of watermark in %
  
  [parameter(Mandatory=$false, HelpMessage="Please enter the relative size that the watermark will have (compared to the watermarked image, valid range is 0% - 100%")]
  [ValidateRange(0,100)]
  [single]
  $watermarkSizeRel = 6.94, #size of watermark compared to image in %

  [parameter(Mandatory=$false)]
  [ValidateScript({
    #does parent folder exist?
    $ParentFolder = Split-Path -Path $_
    Test-Path -Path $ParentFolder -PathType ‘Container’}
  )]
  [String]
  $Destination = '.\watermark', #the watermarked images go into this folder

  [parameter(Mandatory=$false)]
  [String]
  $Suffix = $null, #add this to the file name of the watermarked images

  [parameter(Mandatory=$false)]
  [switch]
  $Replace,    #decides what happens if a file already exists in the destination folder
               #default: do not replace the existing file. no new watermarked file will be created
               #replace: replace existing file with a new, watermarked file (can be used when switching to a new watermark)

  [parameter(Mandatory=$false)]
  [switch]
  $KeepMetaData,   #remove EXIF file metadata
                   #$default: remove metadata
  
  [parameter(Mandatory=$false)]
  [ValidateSet('NorthWest', 'North', 'NorthEast', 'West', 'Center', 'East', 'SouthWest', 'South', 'SouthEast')]
  [String]
  $Gravity = 'SouthEast'   #watermark image file
)

$ScriptName = 'add-watermark-to-image'
$ScriptVersion = '1.002'
$ScriptDate = [DateTime]'2022-11-27' 
$WrittenBy ='Carl'

#display script info
$ScriptInfo = 'version ' + $ScriptVersion + ', ' + (Get-Date -Date $ScriptDate -Format d) + ', written by ' + $WrittenBy
write-host $ScriptName
write-host $ScriptInfo

#display start parameters
write-host `n'path to images:' $Source
foreach ($ImageFileExtension in $ImageFileExtensions) {
  $ImageFileExtensionsCommaSeparated += $ImageFileExtension
  if ($ImageFileExtensions.IndexOf($ImageFileExtension) -lt ($ImageFileExtensions.count -1)) {
    $ImageFileExtensionsCommaSeparated += ', '
  }
}
write-host 'image file extensions:' $ImageFileExtensionsCommaSeparated
write-host 'watermark file:' $WatermarkImage
write-host 'watermark relative size:' ('{0:n2}%' -f $watermarkSizeRel) #format to two decimal places
write-host 'watermark opacity:' ('{0:n2}%' -f $Opacity) #format to two decimal places
write-host 'destination folder:' $Destination `n

#find out what paths look like in the operating system
#in Windows, this the separator char is '\', for example 'c:\temp'
#in Linux, it is '/', for example '/tmp'
#this will be needed later when we build the file path for the watermarked pictures
$DirectorySeparatorChar = [IO.Path]::DirectorySeparatorChar

#set temp watermark location
$Platform = $PSVersionTable.Platform
if ($Platform -eq 'Win32NT') {
  #Windows
  $tempWatermarkPath = $env:TEMP + $DirectorySeparatorChar #this should be C:\Users\<username>\AppData\Local\Temp\
}
elseif ($Platform -eq 'Unix') {
  #Linux
  $tempWatermarkPath = $DirectorySeparatorChar + 'tmp' + $DirectorySeparatorChar #this should be /tmp/
  #In Ubuntu, $env:TEMP does not work and neither does $env:TMPDIR ($TMPDIR)
} 
 $tempWatermark = $tempWatermarkPath + 'tempWatermark.png'

#get watermark image height
[int]$watermarkHeight = magick identify -ping -format '%h' $WatermarkImage

#create folder for watermarked images if it does not exist
if ((Test-Path -Path $Destination) -eq $false) {
  New-Item -Path $Destination -ItemType "directory" | out-null
}
else {
  #if folder exists, 
  If ( Test-Path -Path ($Destination + $DirectorySeparatorChar + '*') ) {
    if ( -not $Replace) {
      #folder exist, has content but -Replace was not specified
      $FolderHasContentWarning = 'Folder ' + $Destination + ' exists and has content. ' + `
        'If you want to replace files with new watermarked files, use "-Replace". ' + `
        'If you proceed, exisitng files will not be overwritten.'
      Write-Warning -Message $FolderHasContentWarning
      $confirmation = Read-Host -Prompt "Are you Sure You Want To Proceed? (y/n)"
      if ($confirmation -eq 'n') {
        exit
      }
    }
  }
}

#copy folder structure without files
Copy-Item -Path ($source + $DirectorySeparatorChar + '*') `
  -Destination $Destination -Force  -Exclude '*.*' -Recurse

#find images
#file extensions, example: 'jpg' --> '*.jpg'
$ImageFileExtensionsAsterisk = @()
foreach ($ImageFileExtension in $ImageFileExtensions) {
  $ImageFileExtensionsAsterisk += ('*.' + $ImageFileExtension)
}

#find only files with desired file extensions as specified in $ImageFileExtensions
$sourceImages = Get-ChildItem -Path $Source -Recurse -ErrorAction SilentlyContinue -Force -Include $ImageFileExtensionsAsterisk

foreach ($sourceImage in $sourceImages) {

  #write progress
  if ($sourceImages.count -eq 1) {
    $PercentComplete = 0
  }
  else {
    $PercentComplete = ($sourceImages.IndexOf($sourceImage) / $sourceImages.count) * 100
  }
  Write-Progress -Activity 'processing' -Status $sourceImage.Name -PercentComplete $PercentComplete

  #create result image file name
  #get the source file's parent folder
  #example: 'C:\pics\picset01\pic01.jpg' --> C:\pics\picset01
  $SourceParentFolder = Split-Path -Path $sourceImage -Parent

  <# get file's parent folder's relative path to the source folder
     example: source folder is:     $source             = 'C:\pics', 
     file path is:                  $sourceImage        = 'C:\pics\picset01\pic01.jpg' 
     file's parent folder is:       $SourceParentFolder = 'C:\pics\picset01
     relative path is:              $RelativePath       =         'picset01' #> 
  $RelativePath = [System.IO.Path]::GetRelativePath($Source, $SourceParentFolder) #this is a string

  #building the destination image path and filename
  $resultImage = ($Destination +    #C:\watermarked (continued example from above)
    $DirectorySeparatorChar +       #C:\watermarked\
    $RelativePath +                 #C:\watermarked\picset01
    $DirectorySeparatorChar  +      #C:\watermarked\picset01\
    $sourceImage.BaseName +         #C:\watermarked\picset01\pic01
    $Suffix +                       #C:\watermarked\picset01\pic01 w (suffix = ' w')
    $sourceImage.Extension)         #C:\watermarked\picset01\pic01 w.jpg

  #check if destination file already exists
  if (Test-Path -Path $resultImage -PathType Leaf) {
    #file exists
    #will the file be replaced with a new watermarked file?
    if ( -not $Replace) {
      write-host 'file exists. Skipping' $sourceImage
      continue #skip this file
    }
    else {
      #remove watermarked image if present
      remove-item $resultImage 
    }
  }

  #get source image height
  [int]$sourceHeight = magick identify -ping -format '%h' $sourceImage

  #calculate new watermark size in pixels
  #this is based on the ratio (watermarkSizeRel) of watermark height to image height 
  [int]$watermarkSizePixels = $sourceHeight * ($watermarkSizeRel / 100)

  #calculate new watermark size in %
  $watermarkSizePercentage = ( $watermarkSizePixels / $watermarkHeight ) * 100

  #create new watermark
  if (Test-Path -Path $tempWatermark -PathType Leaf) {
    remove-item $tempWatermark
  }
  magick $WatermarkImage -resize ([string]$watermarkSizePercentage + '%') $tempWatermark

  #remove EXIF data?
  if ($KeepMetaData) {
    $strip = $null
  }
  else {
    $strip = '-strip'
  }

  #create new image with watermark
  $MagickArguments = @(
    $sourceImage.FullName,
    $strip, $tempWatermark,
    '-gravity',$Gravity,
    '-define',('compose:args=' + $Opacity + ',100'),
    '-compose',
    'dissolve',
    '-composite',
    $resultImage
  )
  magick $MagickArguments

  #remove temp watermark
  remove-item $tempWatermark

}




