
<#
add-watermark-to-image.ps1
batch watermark image and remove metadata 
Nov 19, 2022
V1.01
written by Carl
#>

Param(
  [parameter(Mandatory=$true)] [String]$pathToOriginalPictures,
  [parameter(Mandatory=$true)] [String]$watermarkImage,
  [parameter(Mandatory=$false)] [single]$dissolve = 100, #opacity of watermark in %
  [parameter(Mandatory=$false)] [single]$watermarkSizeRel = 6.94, #size of watermark compared to image in %
  #[parameter(Mandatory=$false)] $imageFileFormats = @("jpg", "jpeg", "png")
  [parameter(Mandatory=$false)] [String]$pathToWatermarkedPictures = '\watermark'
)

$ScriptVersion = '1.002'
[DateTime]$ScriptDate = '2022-11-26'
$WrittenBy ='Carl'

#set temp watermark location
$Platform = $PSVersionTable.Platform
$Platform
if ($Platform -eq 'Win32NT') {
  #Windows
  $tempWatermarkPath = $env:TEMP + '\'
}
elseif ($Platform -eq 'Unix') {
  #Windows
  $tempWatermarkPath = '\tmp\'
} 
 $tempWatermark = $tempWatermarkPath + 'tempWatermark.png'

#output options
write-host  

#create folder for watermarked images if it does not exist
if (Test-Path -Path ($pathToWatermarkedPictures -eq $false)) {
  New-Item -Path $pathToOriginalPictures -Name $WatermarkedPicturesFolderName -ItemType "directory"
}

#copy images to watermarked folder
write-host 'copying'
Copy-Item -Path $pathToOriginalPictures -Destination $pathToWatermarkedPictures -Recurse -Force

#find images
$sourceImages = Get-ChildItem -Path $pathToWatermarkedPictures -Recurse -ErrorAction SilentlyContinue -Force -Include *.jpg, *.jpeg, *.png

#get watermark image height
[int]$watermarkHeight = magick identify -ping -format '%h' $watermarkImage

foreach ($sourceImage in $sourceImages) {

  #write progress
  $PercentComplete = ($sourceImages.IndexOf($sourceImage) / $sourceImages.count) * 100
  Write-Progress -Activity 'processing' -Status $sourceImage.BaseName -PercentComplete $PercentComplete

  #get source image height
  [int]$sourceHeight = magick identify -ping -format '%h' $sourceImage

  #calculate new watermark size in pixels
  [int]$watermarkSizePixels = $sourceHeight * ($watermarkSizeRel / 100)

  #calculate new watermark size in %
  $watermarkSizePercentage = ( $watermarkSizePixels / $watermarkHeight ) * 100

  #create new watermark
  if (Test-Path -Path $tempWatermark -PathType Leaf) {
    remove-item $tempWatermark
  }
  magick $watermarkImage -resize ([string]$watermarkSizePercentage + '%') $tempWatermark

  #create result image file name
  $resultImage = $sourceImage.DirectoryName + '\' + $sourceImage.BaseName + ' w' + $sourceImage.Extension
  
  #remove watermarked image if present
  if (Test-Path -Path $resultImage -PathType Leaf) {
    remove-item $resultImage
  }

  #create new image with watermark
  $MagickArguments = @(
    $sourceImage.FullName,
    '-strip',$tempWatermark,
    '-gravity','southeast',
    '-define',('compose:args=' + $dissolve + ',100'),
    '-compose',
    'dissolve',
    '-composite',
    $resultImage
  )

  magick $MagickArguments
  
  #remove original from watermark folder
  remove-item $sourceImage

  #remove temp watermark
  remove-item $tempWatermark

}




