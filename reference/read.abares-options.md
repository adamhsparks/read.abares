# Package Options for read.abares

This page documents the global options used by the read.abares package.

## Details

The following options can be set via \[options()\] to control package
behavior:

- `read.abares.user_agent`:

  Character string to set a custom user agent for web requests. Default
  is
  `read.abares R package {version no.} https://github.com/adamhsparks/read.abares`.

- `read.abares.timeout`:

  Integer providing the timeout in seconds for download operations.
  Default is `2000`.

- `read.abares.timeout_connect`:

  Integer providing the connection timeout in seconds. Default is `20`.

- `read.abares.max_tries`:

  Integer providing the number of times to retry download before giving
  up. Default is `3`.

- `read.abares.verbosity`:

  Set the desired level of verbosity.

  - "quiet" - no messages at all but errors will be reported,

  - "minimal" - warnings and errors only reported,

  - "verbose" - full messages including downloading, importing files,
    etc. reported.

These options can be set globally using:

    options(read.abares.user_agent = "myCustomUserAgent") or
    read.abares_options(read.abares.user_agent = "myCustomUserAgent")

    [options()]: R:options()

## See also

[`options()`](https://rdrr.io/r/base/options.html),
[`getOption()`](https://rdrr.io/r/base/options.html).

Other read.abares-options:
[`read.abares_options()`](https://adamhsparks.github.io/read.abares/reference/read.abares_options.md)
