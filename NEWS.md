# read.abares 1.0.0

## Breaking changes

* Rename functions that both download and read files into active R session from `get_` to `read_` to avoid confusion with functions that only fetch data and have separate `read_` functions

* Adds new function, `print_agfd_nc_file_format()` to provide details on the AGFD NetCDF files' contents

* Uses Geopackages for {sf} objects rather than .Rds, faster and smaller file sizes when caching

* Checks and corrects the geometries of the AAGIS Regions shapefile upon import and applies to the cached object if applicable

## New features

* Improved documentation

  * All data sets now have an `@source` field that points to the file being provided
  
  *  All data sets now have an `@references` field that points to references for the data

* Code linting thanks to [{flint}](https://flint.etiennebacher.com)

* Use {httr2} to handle downloads

  * Increase timeout values to deal with stubborn long-running file downloads
  * Uses {httr2}'s caching functionality to simplify in-session caching
  
* Use {brio} to write downloads to disk

* Use {httptest2} to help test downloads

* Gracefully handle errors when AGFD zip files are corrupted on download, provide the user with an informative message and remove corrupted download

* Tests are run in parallel for quicker testing

* {sf} operations are now quiet when reading data where possible

## Minor improvements and fixes

* No longer checks the length of a Boolean vector when checking the number of files in the cache before proceeding with removing them

* Fixes bugs in `get_agfd()` when creating the directories for saving the downloaded file

* Fixes bug in `get_aagis_regions()` when creating the cached object file

* Fixes "URL" field in DESCRIPTION file (@mpadge <https://github.com/adamhsparks/read.abares/issues/1>)

# read.abares 0.1.0

- Submission to rOpenSci for [peer code review](https://github.com/ropensci/software-review/issues)
