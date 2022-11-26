# changelog
### Unreleased
- improved performance by no longer creating unnecessary copies of images  
Explanation: Previously, the source file was copied into the destination folder. The copy was then used to create a new watermarked image. Then the copy was deleted. Now, the watermarked image is created directly from the source file. No copies are made, which greatly improves performance
- changed name of parameter -dissolve to -opacity
- display options before starting
- change name of parameter -pathToOriginalPictures to -SourceImages

### v1.002 - 2022-11-25
- Added 
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