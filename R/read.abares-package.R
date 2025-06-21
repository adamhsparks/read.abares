#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom data.table :=
#' @importFrom data.table .BY
#' @importFrom data.table .EACHI
#' @importFrom data.table .GRP
#' @importFrom data.table .I
#' @importFrom data.table .N
#' @importFrom data.table .NGRP
#' @importFrom data.table .SD
#' @importFrom data.table data.table
#' @importFrom data.rable %notin%
## usethis namespace: end
NULL


#' Read collaborators.txt
#'
#' Reads a text file containing GitHub usernames of collaborators.
#' @returns a vector of GitHub usernames.
#'
#' @author Adam H. Sparks and Maëlle Salmon
#' via (<https://github.com/EMODnet/emodnet.wfs/blob/69ca933e5a4154cb651b1d3158072f86d0a7ccb9/R/emodnet.wfs-package.R).
#' @dev
.readabares_collaborators <- function() {
  readLines(system.file("collaborators.txt", package = "read.abares"))
}

#' Create a custom user-agent string
#'
#' Creates the user-agent string for \pkg{read.abares} for default values based
#'  on whether the use is CI/development or interactive use.
#'
#' @returns A character string to be used by \CRANpkg{httr2} as a user-agent.
#'
#' @author Adam H. Sparks and Maëlle Salmon
#' via (<https://github.com/EMODnet/emodnet.wfs/blob/69ca933e5a4154cb651b1d3158072f86d0a7ccb9/R/emodnet.wfs-package.R).
#' @dev
readabares_user_agent <- function() {
  readabares_version_string <- as.character(utils::packageVersion(
    "read.abares"
  ))
  readabares_r_package_string <- "read.abares R package"
  readabares_url_string <- "https://github.com/adamhsparks/read.abares"

  if (nzchar(Sys.getenv("READABARES _CI"))) {
    return(
      sprintf(
        "%s %s CI %s",
        readabares_r_package_string,
        readabares_version_string,
        readabares_url_string
      )
    )
  }
  # I've had to set my GITHUB_USERNAME in .Renviron to make this work properly
  # A .Renviron now lives in my directory where I do package development with
  # this value rather than pollute my global .Renviron if I were to use this
  # package for work and not development
  gh_username <- try(whoami::gh_username(), silent = TRUE)
  if (
    !inherits(gh_username, "try-error") &&
      gh_username %in% .readabares_collaborators()
  ) {
    return(
      sprintf(
        "%s %s DEV %s",
        readabares_r_package_string,
        readabares_version_string,
        readabares_url_string
      )
    )
  }

  sprintf(
    "%s %s %s",
    readabares_r_package_string,
    readabares_version_string,
    readabares_url_string
  )
}
