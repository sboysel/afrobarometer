library(testthat)
context("afrb_dir")

rand_string_n <- function(n = 10) {
  stopifnot(is.finite(n), n > 0)
  paste0(sample(x = c(letters, LETTERS, 1:9), size = n, replace = TRUE), collapse = "")
}

temp_dir <- function() {
  tmp <- file.path(tempdir(), rand_string_n(n = 20))
  dir.create(tmp)
  tmp
}

tmp <- temp_dir()

test_that("afrb_dir", {
  suppressMessages(dir <- afrb_dir(path = tmp))
  op <- options()
  expect_identical(dir, getOption("afrobarometer.data"))
  expect_true(all(c("afrobarometer.data") %in% names(op)))
  expect_true(dir.exists(tmp))
  expect_true(dir.exists(file.path(tmp, "questionnaires")))
  expect_true(dir.exists(file.path(tmp, "locations")))
  expect_true(dir.exists(file.path(tmp, "codebooks")))
})

unlink(tmp)
