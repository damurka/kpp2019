# These guard the invariants used to validate pop1/pop5/components against
# the source KNBS workbook (see data-raw/prepare-data.R and NEWS.md). They
# run on every check/CI build, so a future data refresh (or a hand-edited
# .rda) that reintroduces a misaligned/corrupted cell fails loudly here
# instead of shipping silently.

test_that("no missing values", {
  expect_false(anyNA(pop1$pop))
  expect_false(anyNA(pop5$pop))
  expect_false(anyNA(components$value))
})

test_that("pop1 and pop5 have no duplicate county/age/year/gender rows", {
  expect_equal(anyDuplicated(pop1[c("county", "age", "year", "gender")]), 0)
  expect_equal(anyDuplicated(pop5[c("county", "age", "year", "gender")]), 0)
})

test_that("components has no duplicate county/component/year rows", {
  expect_equal(anyDuplicated(components[c("county", "component", "year")]), 0)
})

male_female_total_max_diff <- function(df) {
  key <- c("county", "age", "year")
  m <- merge(df[df$gender == "Male", c(key, "pop")],
             df[df$gender == "Female", c(key, "pop")],
             by = key, suffixes = c(".male", ".female"))
  m <- merge(m, df[df$gender == "Total", c(key, "pop")], by = key)
  max(abs((m$pop.male + m$pop.female) - m$pop))
}

test_that("Male + Female equals Total in pop1 and pop5", {
  expect_lt(male_female_total_max_diff(pop1), 1e-3)
  expect_lt(male_female_total_max_diff(pop5), 1e-3)
})

all_ages_sum_max_diff <- function(df) {
  summed <- aggregate(pop ~ county + year + gender, data = df[df$age != "All Ages", ], sum)
  all_ages <- df[df$age == "All Ages", c("county", "year", "gender", "pop")]
  m <- merge(summed, all_ages, by = c("county", "year", "gender"), suffixes = c(".sum", ".allages"))
  max(abs(m$pop.sum - m$pop.allages))
}

test_that("sum of age groups equals the 'All Ages' row in pop1 and pop5", {
  expect_lt(all_ages_sum_max_diff(pop1), 1)
  expect_lt(all_ages_sum_max_diff(pop5), 1)
})

test_that("Births - Deaths equals Nat. Inc. in components", {
  key <- c("county", "year")
  m <- merge(components[components$component == "Births", c(key, "value")],
             components[components$component == "Deaths", c(key, "value")],
             by = key, suffixes = c(".births", ".deaths"))
  m <- merge(m, components[components$component == "Nat. Inc.", c(key, "value")], by = key)
  expect_lt(max(abs((m$value.births - m$value.deaths) - m$value)), 1)
})

test_that("pop1 and pop5 agree at the checkpoint years they share", {
  shared_years <- c(2020, 2025, 2030, 2035)
  key <- c("county", "age", "year", "gender")
  m <- merge(pop1[pop1$year %in% shared_years, c(key, "pop")],
             pop5[pop5$year %in% shared_years, c(key, "pop")],
             by = key, suffixes = c(".pop1", ".pop5"))

  expect_equal(nrow(m), sum(pop1$year %in% shared_years))
  expect_lt(max(abs(m$pop.pop1 - m$pop.pop5)), 1e-3)
})
