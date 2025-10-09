# Response to reviewers

## potterzot

> [README.md]: I know pak is more prevalent these days, but wonder if including remotes::install_github() as an option would be useful for folks who don't use pak.

The README.md now has instructions for using {remotes} as well as {pak} and why you might prefer to use {pak} over {remotes} on Linux for spatial library installations.

> In the vignette several commands took quite a long time to run. I think the same instructional point could be made with fewer regions/years. I can see that it isn't possible to query specific subsets of data, but before merging and plotting might be helpful to speed up the vignette. I encountered these slow points in particular:
> [vignette/read.abares.Rmd] Line 80: The command aagis_dat <- left_join(aagis_regions, aagis_region_data) took 70 seconds on my laptop.

This now joins only one year, 2023, and is much faster.

> [vignette/read.abares.Rmd] Lines 95-102: The ggplot took a while to render
> [vignette/read.abares.Rmd] Lines 95-102: This fetch command took at least 3 minutes and made my laptop lag: star <- get_agfd(cache = TRUE) |> read_agfd_stars(). Reducing the dimensions here would also make it so taht when a new user / this reviewer types star in the terminal they aren't swamped with a lot of printed data that has to be cancelled out of. The same is true for read_agfd_terra, read_agfd_tidync, and read_agfd_dt. If it can't be done via query,

The {stars} example now only returns the year 2000, diminishing the text and time it takes to process locally and render the plot.

> [DESCRIPTION] When running tests I received two warnings about needing to install bit64 to properly display integer64 values. Maybe adding this package to suggests?

{bit64} has been added to Suggests.

## mpaulacaldas

> ### Vignette
>
> Like @potterzot, I find some of the operations in the vignette take a long time to render, notably plot(aagis_regions). Likewise, in the example in lines 71 to 103, I would suggest filtering the data before the left_join(), to reduce the time of the left_join().

As above, this now is more efficient processing only one year.
The download is still slow, but local operations are much faster.

> I think users of this package will likely rely quite heavily on the cache, so it may be useful to learn about inspect_cache() in the vignette.

For several reasons, I removed caching functionality and point users towards using {targets} instead.

> This is a minor note, but library(read.abares) is mentioned at the top of each section. Were you planning on having separate vignettes? If you have only one vignette, the library call becomes a bit redundant.
> Functionality

I've removed it, but had it just so you could easily execute any code chunk as a standalone.

> Failing downloads
> Unfortunately, several functions don't work on my end. I didn't have a lot of time to debug (but I'm happy to help you out with it if you like), but it appears that all estimate downloads get blocked at the level of .retry_download(). The functions that don't work for me:
>
> read_estimates_by_performance_category()
> read_estimates_by_size()
> read_historical_national_estimates()
> read_historical_state_estimates()
> read_historical_regional_estimates()
> Tests for retry_download() pass. I also don't have issues with the download of most other assets. I leave below my session info for reference.

The agriculture server that has these files appears to be very poorly configured from the responses I can gather using curl and other tools.
I've done my best to address this shortcoming with custom headers and other curl commands.
However, realising that it may not always work, all of the `read_` functions now support an argument, `x`, which is the unarchived folder that users may download from the website using their browser to import and parse the data, skipping problematic downloads in R.

> Session info
> Error with data.table::fread()
> read_abares_trade() also fails in my machine, but at the data.table level.
>
> trade <- read_abares_trade()
> #> Error in data.table::fread(trade_zip) :  
> #> embedded nul in string: 'PK\003\004\024\0\0\0\b\0-#> U\xa7Z\v\021\x82/\vgG\t\x9e\xa0iT\025\0\0\0ABARES_trade_data.csvĽ]\x93d\xb9q\xa6y\xbff\xfb\037\xd2\xfa\x8a\xb2\xadL\x83'
> inspect_cache() doesn't work as expected
> That is, it doesn't actually return the absolute paths of the files in the cache. This is what I get:
>
> p <- inspect_cache()
> #>
> #> ── Locally Available {read.abares} Cached Files ─────────────────────────────────────────
> #> • aagis_regions_dir
> #> • historical_climate_prices_fixed
> #> • topsoil_thickness_dir
> unclass(p)
> #> [1] "cli-69638-30"
> Looking at the code, I see this is because the function doesn't actually return f (the paths) after the cli messages. You could fix this by returning invisible(f) after the cli messages.
>
> I would also suggest adding a unit test for the value returned by inspect_cache(), as the current tests only focus on the cli output.

Caching has been removed.

> Function documentation
> In the examples of inspect_cache(), it would be easier if you stick to either fs functions (e.g. fs::path_file() and fs::path_dir()) or to their base equivalent (basename() and dirname()), instead of mixing the two.

Thanks! Yes, I've addressed this where necessary.
With the updated functionality, not caching, and other changes, there are fewer examples that use this sort of code.

> Package API
> Below are some "nice-to-have's", but please don't feel like you have to address them:
>
> As per the rOpenSci guidelines, it would be useful to give users the choice to override the user agent for the API requests preformed behind the scenes by .retry_download(). In addition of the user agent, I also quite like having the ability to override the timeout, so things can "fail fast" if I need them to.
> It would be nice let users choose the location of the cache directory or to opt out of informative messages via environment variables or global options.

Users can now set several options related to downloading and package verbosity:

- User-agent string for downloads,
- Timeout for downloads,
- Connect-timeout for downloads,
- Number of download retries and
- Verbosity of the package's messages.

Thank you both for your insightful and thorough feedback.
It improved the package.

While I was working on it, I added a few more data sources:

- National (NLUM) and catchment (CLUM) level land use,
- ABS production data for:
  - broadacre crops including summer, winter and sugarcane,
  - horticulture crops, and
  - livestock.

Caching is no longer supported for simplicity and CRAN-proofing.

Also, the `get_` functions have been retired, using `read_` now will trigger a download if `x` (a file) is not provided.
