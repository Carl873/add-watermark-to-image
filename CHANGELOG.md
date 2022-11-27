# changelog
### Unreleased

### v1.002 - 2022-11-27
- Added
  - Added ability to choose location of watermark
  - Added ability to keep EXIF metadata
  - Added a warning if destination folder is not empty and "-replace" was not specified
  - added option -replace to replace existing files in the destination folder  
    this can be used, to replace previously watermarked files and add a new watermark
  - added option to add a custom suffix to the filename of watermarked files
  - display options before starting
  - added ability to specify image file extensions via parameter -imageFileExtensions
  - Display script version info
  - Input for parameter -opacity is now validated to be within the range 0-100
  - Input for parameter -watermarkSizeRel is now validated to be within the range 0-100
  - Input for parameters that contain a path are now validated
  - Input for parameter -imageFileExtensions is now validated
  - All mandatory parameters now have help message. If the parameter is not specified a hint can be displayed by entering "!?"
- Changed
  - improved performance by no longer creating unnecessary copies of images  
    Explanation: Previously, the source file was copied into the destination folder. The copy was then used to create a new watermarked image. Then the copy was deleted. Now, the watermarked image is created directly from the source file. No copies are made, which greatly improves performance 
  - removed the previously hardcoded suffix " w" from watermarked files
    By default, the filename of the watermarked image will be the same as the name of the source image.  
    optionally, a custom suffix can now be added.
- Fixed
  - fixed an issue that prevented the script from completing if only 1 file was watermarked

- Changed
  - If -pathToWatermarkedPictures is not specified, watermarked pictures will be saved in current folder.  
  Previously, watermarked pictures were save to the root folder of the file system, -pathToWatermarkedPictures was not specified
- changed name of parameter -dissolve to -opacity
- changed name of parameter -pathToOriginalPictures to -Source
- changed name of parameter -pathToWatermarkedPictures to -Destination

### v1.002 - 2022-11-26
- Changed
  - changed default opacity to 100%
  - removed some hardcoded local paths that were used if no parameters where specified
- Notes
  - uploaded first version to Github
### v1.001 2022-11-25
- Fixed
  - watermark opacity parameter works now  
    Previously, the -dissolve parameter was ignored and a hardcoded value was used
- Changed
  - changed default opacity to 70%
### v1.00 2022-11-19
- Notes
  - first version