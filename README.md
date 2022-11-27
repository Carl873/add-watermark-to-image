# add-watermark-to-image

### Contents
- [About](#About)
- [Requirements](#Requirements)
- [Installation (Ubuntu)](#Installation)
- [Options](#Options)
- [Examples)](#Examples)


### About

- This script adds an image watermark to a picture using ImageMagick. Can also strip file metadata (EXIF data). The original file is always retained.
- Features
  - ability to recursively watermark all files in a folder
  - ability to include or exclude files based on file extension  
    Example: jpg, jpeg, png, etc.
  - ability to add a suffix to watermarked files  
    Example: "image01.jpg" becomes "image01 watermarked.jpg"
  - ability to replace already watermarked files
  - automatically resizes watermark size relative to the size of the image    that is watermarked.  
    The ratio can be configured.
  - ability to remove (EXIF) file metadata  
    This removes location info, camera info, etc.
  - adjustable watermark opacity
  - option to retain the original filename or add a configurable suffix to it  
    Example: 'original.jpg' --> 'original watermarked.jpg'
  - runs on Windows and Linux  
    tested on Windows 11, Ubuntu 22.04.1 LTS

### Requirements

  - PowerShell 7  
    It is unlikely that this script will run on old PS versions
  - ImageMagick version 7  
    Due to commands being executed in a different way in Magick 7, it will not run on Magick 6 and older.
  - For Linux, see instructions below

### Installation (Ubuntu)

#### Install ImageMagick

 - Uninstalling old version  
    If you have installed Magick using
    ```
    sudo apt install imagemagick
    ```
    on Ubuntu 22.04.1 LTS, you will most likely have an old version (version 6) and you need to uninstall the old version first.
    ```
    sudo apt remove imagemagick
    ```
- Download Magick 7
    ```
    wget https://imagemagick.org/archive/binaries/magick
    ```
- Make the file executable
    ```
    chmod +x magick
    ```
- Move file /usr/bin/ so you can run it from everywhere
    ```
    sudo mv magick /usr/bin/
    ```
- Confirm that you can run it and that it is version 7 or higher
    ```
    magick -version
    ```
    output should look like this
    ```
    Version: ImageMagick 7.1.0-52 Q16-HDRI x86_64 36d3408b5:20221106 https://imagemagick.org
    Copyright: (C) 1999 ImageMagick Studio LLC
    License: https://imagemagick.org/script/license.php
    Features: Cipher DPC HDRI OpenMP(4.5)
    Delegates (built-in): bzlib djvu fontconfig freetype jbig jng jpeg lcms lqr lzma openexr png raqm tiff webp x xml zlib
    Compiler: gcc (7.5)
    ```

#### Install PowerShell
  - Microsoft recommended way
    - download PowerShell
      ```
      wget https://github.com/PowerShell/PowerShell/releases/download/v7.3.0/powershell_7.3.0-1.deb_amd64.deb
      ```

    - Install the downloaded package
      ```
      sudo dpkg -i powershell_7.3.0-1.deb_amd64.deb
      ```
    - Resolve missing dependencies and finish the install (if necessary)
      ```
      sudo apt-get install -f
      ```
  - using Snap
      ```
      snap install powershell --classic
      ```

  
#### Start PS
  - if downloaded, installed manually
    ```
    /opt/microsoft/powershell/7/pwsh
    ```
  - if installed using Snap
    ```
    powershell
    ```
  - confirm that you have PS 7 or higher
    ```
    $PSVersionTable.PSVersion
    ```
    output should be similar to
    ```
    Major  Minor  Patch  PreReleaseLabel BuildLabel
    -----  -----  -----  --------------- ----------
    7      3      0
    ```

### Options
  - -Source  
    tells the script where the pictures are that will be watermarked  
    provide a path to a folder  
    Example:  
    This will watermark all pictures in Z:\upload\watermarktest\SourceFiles and its subfolders
    ```
    -Source 'Z:\upload\watermarktest\SourceFiles'
    ```
  - -imageFileExtensions  
    tells the script which file extensions will be included  
    default extensions: jpg, jpeg, png  
    Example:  
    This will include all *.jpg, *.jpeg, *.png files
    ```
    -imageFileExtensions ("jpg", "jpeg", "png")
    ```
  - -WatermarkImage  
    tells the script where the watermark image is  
    provide an image file  
    Example:
    ```
    -WatermarkImage 'Z:\upload\watermarktest\watermark image.png'
    ```
  - -Opacity  
    adjusts the watermark opacity in percent  
    provide a number between 0 and 100
    default value: 100%  
    example  
    This will add a watermark with 70% opacity
    ```
    -Opacity 70
    ```
  - -watermarkSizeRel  
    adjusts the size of the watermark relative to the size of the image that will be watermarked in percent  
    provide a number between 0 and 100  
    note, that only the image height is considered for this
    example:  
    In this example
      - the watermark image is 200x100 pixels  
      - the source image is 4160x3120 pixels
      - watermarkSizeRel is 10 (10%)
      - The result is: The watermark will be upscaled to 624x312 pixels, then applied to the image
    ```
    -watermarkSizeRel 10
    ```
  - -Destination  
    tells the script where the watermarked pictures will be stored  
    provide a path to a folder  
    example:  
    this will save the watermarked pictures to Z:\upload\watermarktest\WatermaredFiles
    ```
    -Destination 'ZZ:\upload\watermarktest\WatermaredFiles'
    ```
  - -Suffix
    tells the script to append the file name of the watermarked file  
    provide a string  
    example:  
    if you want all watermarked file to end with ' watermarked', provide
    ```
    -Suffix ' watermarked'
    ```
    If applied to image 'image01.jpg' the resulting file will be 'image01 watermarked.jpg'.
  - -replace  
    tells the script to replace files in the destination folder if they already exist  
    this can be used to apply a new watermark to files that are already watermarked, provided that the un-watermarked source files are still available
    ```
    -replace
    ```
  - -KeepMetaData  
    keep EFIX file metadata
    example:  
    ```
    -KeepMetaData
    ```
  - -Gravity  
    this is an ImageMagick parameter that decides where the watermark will go  
    possible values:  
    NorthWest, North, NorthEast, West, Center, East, SouthWest, South, or SouthEast  
    default is 'southeast', which puts the watermark in the lower right corner  
    see: [Annotated List of Command-line Options](https://imagemagick.org/script/command-line-options.php)

### Examples

- Example 1
  - uses default image extensions
  - uses default opacity
  - used default watermark relative size
  - uses default orientation (gravity)
  - uses Windows
    ```
    & './add-watermark-to-image.ps1' `
    -Source 'Z:\upload\watermarktest\source' `
    -WatermarkImage 'Z:\upload\watermarktest\dharma.png' `
    -Destination 'Z:\upload\watermarktest\example1'
    ```
  ![example 1 original image](/assets/example1original.png)
  ![example 1 watermarked image](/assets/example1w.png)

- Example 2
  - uses relative paths
  - uses Windows
    ```
    & '.\add-watermark-to-image.ps1' `
    -Source '.\source' `
    -WatermarkImage '.\dharma.png' `
    -Destination '.\example2'
    ```

- Example 3
  - uses Linux
    ```
    & './add-watermark-to-image.ps1' `
    -Source '/mnt/nas01/upload/watermarktest/source' `
    -WatermarkImage '/mnt/nas01/upload/watermarktest/dharma.png' `
    -Destination '/mnt/nas01/upload/watermarktest/example3'
    ```

- Example 4
  - only watermarks *.jpg files
    ```
    & '.\add-watermark-to-image.ps1' `
    -Source '.\source' `
    -imageFileExtensions ("jpg") `
    -WatermarkImage '.\dharma.png' `
    -Destination '.\example4'
    ```

- Example 5
  - set watermark relative size to 30%
    ```
    & './add-watermark-to-image.ps1' `
    -Source './source' `
    -WatermarkImage './dharma.png' `
    -watermarkSizeRel 30 `
    -Destination './example5'
    ```
    ![example 5 watermarked image](/assets/example5.png)

- Example 6
  - adds file name suffix ' watermark'
    ```
    & '.\add-watermark-to-image.ps1' `
    -Source '.\source' `
    -Suffix ' watermark' `
    -WatermarkImage '.\dharma.png' `
    -Destination '.\example6'
    ```

- Example 7
  - replace watermarked file if it exists
    ```
    & '.\add-watermark-to-image.ps1' `
    -Source '.\source' `
    -WatermarkImage '.\dharma.png' `
    -Destination '.\example7' `
    -replace
    ```

- Example 8
  - keep EXIF metadata
    ```
    & '.\add-watermark-to-image.ps1' `
    -Source '.\source' `
    -WatermarkImage '.\dharma.png' `
    -Destination '.\example8' `
    -KeepMetaData
    ```

- Example 9
  - puts watermark in upper right corner
    ```
    & '.\add-watermark-to-image.ps1' `
    -Source '.\source' `
    -WatermarkImage '.\dharma.png' `
    -Destination '.\example9' `
    -Gravity 'NorthEast'
    ```
    ![example 9 watermarked image](/assets/example9.png)

- Example 10
  - set watermark opacity to 30$
    ```
    & './add-watermark-to-image.ps1' `
    -Source './source' `
    -WatermarkImage './dharma.png' `
    -Opacity 30 `
    -Destination './example10'
    ```
    ![example 10 watermarked image](/assets/example10.png)

### Known Issues
- On Linux, relative paths don't seem to work. Use absolute paths instead