test_that("read_agfd_tidync() returns a tidync object", {
  skip_if_offline()
  skip_on_ci()
  x <- get_agfd() |>
    read_agfd_tidync()

  expect_type(x, "list")
  expect_s3_class(x[[1]], "tidync")
  expect_named(
    x,
    c(
      "f2022.c1991.p2022.t2022.nc",
      "f2022.c1992.p2022.t2022.nc",
      "f2022.c1993.p2022.t2022.nc",
      "f2022.c1994.p2022.t2022.nc",
      "f2022.c1995.p2022.t2022.nc",
      "f2022.c1996.p2022.t2022.nc",
      "f2022.c1997.p2022.t2022.nc",
      "f2022.c1998.p2022.t2022.nc",
      "f2022.c1999.p2022.t2022.nc",
      "f2022.c2000.p2022.t2022.nc",
      "f2022.c2001.p2022.t2022.nc",
      "f2022.c2002.p2022.t2022.nc",
      "f2022.c2003.p2022.t2022.nc",
      "f2022.c2004.p2022.t2022.nc",
      "f2022.c2005.p2022.t2022.nc",
      "f2022.c2006.p2022.t2022.nc",
      "f2022.c2007.p2022.t2022.nc",
      "f2022.c2008.p2022.t2022.nc",
      "f2022.c2009.p2022.t2022.nc",
      "f2022.c2010.p2022.t2022.nc",
      "f2022.c2011.p2022.t2022.nc",
      "f2022.c2012.p2022.t2022.nc",
      "f2022.c2013.p2022.t2022.nc",
      "f2022.c2014.p2022.t2022.nc",
      "f2022.c2015.p2022.t2022.nc",
      "f2022.c2016.p2022.t2022.nc",
      "f2022.c2017.p2022.t2022.nc",
      "f2022.c2018.p2022.t2022.nc",
      "f2022.c2019.p2022.t2022.nc",
      "f2022.c2020.p2022.t2022.nc",
      "f2022.c2021.p2022.t2022.nc",
      "f2022.c2022.p2022.t2022.nc",
      "f2022.c2023.p2022.t2022.nc"
    )
  )
})

test_that("read_agfd_tidync() fails if the input is not a proper object", {
  expect_error(read_agfd_tidync(list(list.files(tempdir()))))
})
