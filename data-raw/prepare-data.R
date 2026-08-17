# code to prepare `pop1`, `pop5` and `components` datasets
#
# Source: Kenya National Bureau of Statistics (2023), 2019 Kenya Population
# and Housing Census Analytical Report on Population Projections, Appendix 5
# ("Projected Population by Age, Sex and County, 2020-2045").
#
# The source workbook has one worksheet trio per area (47 counties + Kenya):
#   - "<code>page1" / "<code>table 1"  Table A (5-yr age groups, 5-yr
#     checkpoints 2020, 2025, ..., 2045) + Table B underneath it
#     (components of population change, 5-yr periods 2020-25, ..., 2041-45)
#   - "<code>page2" / "<code>table 2"  Table C, part 1: 5-yr age groups,
#     annual years 2020-2025
#   - "<code>page4" / "<code>table 4"  Table C, part 2: 5-yr age groups,
#     annual years 2030-2035
#
# The workbook has no annual data for 2026-2029 (there is no "page3"/"table
# 3" sheet). Those four years are reconstructed by linear interpolation
# between the 2025 and 2030 values, which is how the shipped `pop1` dataset
# has always been built (verified against a prior version of data/pop1.rda:
# the 2026-2029 figures matched round(interpolated) to the integer).
#
# Population/value figures are kept at full decimal precision, exactly as
# the source workbook stores them (these are fractional cohort-component
# projections, not literal head counts).

library(readxl)
library(dplyr)
library(tidyr)
library(purrr)
library(stringr)
library(usethis)

xlsx_path <- "data-raw/Kenya and Counties_2020_20235.xlsx"

age_levels <- c(
  "0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39",
  "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79",
  "80+", "All Ages"
)
gender_levels <- c("Female", "Male", "Total")
component_levels <- c(
  "Births", "Deaths", "Nat. Inc.", "Net Mig.", "CBR", "CDR", "CNIR", "CNMR"
)

# ---- sheet index --------------------------------------------------------

sheets <- excel_sheets(xlsx_path)

sheet_index <- tibble(sheet = sheets) %>%
  mutate(
    area_code = str_extract(sheet, "^[A-Za-z0-9]+?(?=(table|page))"),
    type = str_extract(sheet, "[124]$")
  )

stopifnot(
  "Could not classify every sheet name into area_code/type" =
    !anyNA(sheet_index$area_code) && !anyNA(sheet_index$type),
  "Expected exactly one sheet per area for each of table 1/2/4" =
    all(table(sheet_index$area_code) == 3)
)

# process areas in the order they appear in the workbook (Kenya first, then
# counties 01-47) so the combined data frames keep the same row order as
# the shipped datasets
area_order <- sheet_index %>%
  filter(type == "1") %>%
  arrange(match(area_code, unique(area_code))) %>%
  pull(area_code)

sheet_for <- function(code, type) {
  sheet_index %>%
    filter(area_code == code, type == !!type) %>%
    pull(sheet)
}

# ---- low-level readers ---------------------------------------------------

# locate consecutive "Male", "Female", "Total" columns in a header row
find_triplet_starts <- function(header) {
  n <- length(header)
  keep <- logical(0)
  for (i in seq_len(max(n - 2, 0))) {
    keep[i] <- isTRUE(header[i] == "Male") &&
      isTRUE(header[i + 1] == "Female") &&
      isTRUE(header[i + 2] == "Total")
  }
  which(keep)
}

# read an age-by-year-by-gender block (Table A or Table C) from one sheet;
# returns county/age/year/gender/pop in the original row order (age varies
# slowest, then year, then gender as Male/Female/Total)
read_age_block <- function(sheet) {
  raw <- read_excel(xlsx_path, sheet = sheet, col_names = FALSE)
  col1 <- as.character(raw[[1]])

  header_row_idx <- which(col1 == "Age")[1]
  area <- col1[header_row_idx - 1]

  year_row <- as.character(unlist(raw[header_row_idx - 1, ], use.names = FALSE))
  header_row <- as.character(unlist(raw[header_row_idx, ], use.names = FALSE))
  starts <- find_triplet_starts(header_row)
  years <- as.integer(year_row[starts])

  last_row_idx <- which(col1 == "All Ages")[1]
  age_row_idx <- (header_row_idx + 1):last_row_idx
  ages <- col1[age_row_idx]

  map_dfr(seq_along(age_row_idx), function(i) {
    r <- age_row_idx[i]
    map_dfr(seq_along(starts), function(j) {
      c0 <- starts[j]
      tibble(
        county = area,
        age = ages[i],
        year = years[j],
        Male = as.numeric(raw[[c0]][r]),
        Female = as.numeric(raw[[c0 + 1]][r]),
        Total = as.numeric(raw[[c0 + 2]][r])
      )
    })
  }) %>%
    pivot_longer(c(Male, Female, Total), names_to = "gender", values_to = "pop")
}

# read the components-of-change block (Table B) that sits below Table A on
# each area's first sheet
read_components_block <- function(sheet) {
  raw <- read_excel(xlsx_path, sheet = sheet, col_names = FALSE)
  col1 <- as.character(raw[[1]])

  area <- col1[which(col1 == "Age")[1] - 1]

  header_row_idx <- which(col1 == "Comp.")[1]
  periods <- as.character(unlist(
    raw[header_row_idx, 2:6],
    use.names = FALSE
  ))
  comp_row_idx <- (header_row_idx + 1):(header_row_idx + length(component_levels))
  comps <- col1[comp_row_idx]

  # A handful of sheets have the "2020-25" value column corrupted: instead
  # of the figure, it repeats the component's own label as text (e.g. the
  # "Births" row's 2020-25 cell contains "Births"), and every value is
  # shifted one column to the right of where the header says it should be.
  # Detect this by checking whether the first value cell parses as numeric;
  # if not, read the values starting one column later.
  value_start <- 2
  first_value <- suppressWarnings(as.numeric(raw[[value_start]][comp_row_idx[1]]))
  if (is.na(first_value)) {
    value_start <- 3
  }
  value_cols <- value_start + seq_along(periods) - 1

  map_dfr(seq_along(comp_row_idx), function(i) {
    r <- comp_row_idx[i]
    tibble(
      county = area,
      component = comps[i],
      year = periods,
      value = as.numeric(unlist(raw[r, value_cols], use.names = FALSE))
    )
  })
}

# ---- combine per area -----------------------------------------------------

# Table C (annual) and Table A (checkpoint) are meant to agree exactly at
# the years they share (2020/2025 for Table C part 1, 2030/2035 for part
# 2). The source workbook has at least one cell where they don't (Busia,
# age 80+, Female, 2030 - see NEWS.md); when that happens, Table A's figure
# is taken as authoritative and the Table C cell is overwritten with it, so
# a single mis-keyed cell doesn't also poison the years interpolated from
# it (2026-2029, in this case).
fix_against_checkpoint <- function(df, checkpoint, tol = 1e-3) {
  chk <- checkpoint %>%
    filter(year %in% unique(df$year)) %>%
    rename(checkpoint = pop)

  joined <- df %>% left_join(chk, by = c("county", "age", "year", "gender"))

  bad <- joined %>% filter(!is.na(checkpoint), abs(pop - checkpoint) > tol)
  if (nrow(bad) > 0) {
    message(
      "  corrected against Table A checkpoint: ",
      paste(sprintf("%s/%s/%d", bad$age, bad$gender, bad$year), collapse = ", ")
    )
  }

  joined %>%
    mutate(pop = if_else(!is.na(checkpoint) & abs(pop - checkpoint) > tol, checkpoint, pop)) %>%
    select(county, age, year, gender, pop)
}

pop5_list <- vector("list", length(area_order))
pop1_list <- vector("list", length(area_order))
components_list <- vector("list", length(area_order))

for (k in seq_along(area_order)) {
  code <- area_order[k]
  message("Processing area ", k, "/", length(area_order), " (", code, ")")

  sheet1 <- sheet_for(code, "1")
  sheet2 <- sheet_for(code, "2")
  sheet4 <- sheet_for(code, "4")

  area_pop5 <- read_age_block(sheet1)
  pop5_list[[k]] <- area_pop5
  components_list[[k]] <- read_components_block(sheet1)

  early <- read_age_block(sheet2) # 2020-2025, exact
  late <- read_age_block(sheet4) # 2030-2035, exact

  early <- fix_against_checkpoint(early, area_pop5)
  late <- fix_against_checkpoint(late, area_pop5)

  endpoints <- bind_rows(early, late) %>%
    filter(year %in% c(2025, 2030)) %>%
    pivot_wider(names_from = year, values_from = pop, names_prefix = "y")

  interpolated <- endpoints %>%
    crossing(year = 2026:2029) %>%
    mutate(pop = y2025 + (y2030 - y2025) * (year - 2025) / 5) %>%
    select(county, age, gender, year, pop)

  pop1_list[[k]] <- bind_rows(early, interpolated, late) %>%
    arrange(match(age, age_levels), year)
}

pop5_raw <- bind_rows(pop5_list)
pop1_raw <- bind_rows(pop1_list)
components_raw <- bind_rows(components_list)

# ---- finalise datasets ----------------------------------------------------

finalise_pop <- function(df) {
  df %>%
    mutate(
      county = factor(county, levels = sort(unique(county))),
      age = factor(age, levels = age_levels),
      gender = factor(gender, levels = gender_levels),
      year = as.integer(year)
    ) %>%
    select(county, age, year, gender, pop)
}

pop1 <- finalise_pop(pop1_raw)
pop5 <- finalise_pop(pop5_raw)

components <- components_raw %>%
  mutate(
    county = factor(county, levels = sort(unique(county))),
    component = factor(component, levels = sort(component_levels)),
    year = factor(year, levels = sort(unique(year)))
  ) %>%
  select(county, component, year, value)

# ---- sanity checks ---------------------------------------------------------

# Male + Female must equal Total in every (county, age, year) group
check_male_female_total <- function(df, tol = 1e-3) {
  wide <- df %>%
    select(county, age, year, gender, pop) %>%
    pivot_wider(names_from = gender, values_from = pop)
  bad <- wide %>% filter(abs((Male + Female) - Total) > tol)
  if (nrow(bad) > 0) {
    message("Male + Female != Total for:")
    print(bad)
  }
  nrow(bad) == 0
}

# the "All Ages" row must equal the sum of the individual age groups, for
# every (county, year, gender)
check_all_ages_sum <- function(df, tol = 1) {
  summed <- df %>%
    filter(age != "All Ages") %>%
    group_by(county, year, gender) %>%
    summarise(summed = sum(pop), .groups = "drop")
  all_ages <- df %>%
    filter(age == "All Ages") %>%
    select(county, year, gender, pop)
  bad <- inner_join(summed, all_ages, by = c("county", "year", "gender")) %>%
    filter(abs(summed - pop) > tol)
  if (nrow(bad) > 0) {
    message("sum(age groups) != All Ages for:")
    print(bad)
  }
  nrow(bad) == 0
}

# Births - Deaths must equal Nat. Inc. in every (county, year) group
check_births_deaths <- function(df, tol = 1) {
  wide <- df %>% pivot_wider(names_from = component, values_from = value)
  bad <- wide %>% filter(abs((Births - Deaths) - `Nat. Inc.`) > tol)
  if (nrow(bad) > 0) {
    message("Births - Deaths != Nat. Inc. for:")
    print(bad[, c("county", "year")])
  }
  nrow(bad) == 0
}

stopifnot(
  "pop1 has the expected number of rows" =
    nrow(pop1) == length(area_order) * length(age_levels) * 16 * 3,
  "pop5 has the expected number of rows" =
    nrow(pop5) == length(area_order) * length(age_levels) * 6 * 3,
  "components has the expected number of rows" =
    nrow(components) ==
      length(area_order) * length(component_levels) * 5,
  "no missing population values" = !anyNA(pop1$pop) && !anyNA(pop5$pop),
  "no missing component values" = !anyNA(components$value),
  "Male + Female == Total in pop1" = check_male_female_total(pop1),
  "Male + Female == Total in pop5" = check_male_female_total(pop5),
  "sum(age groups) == All Ages in pop1" = check_all_ages_sum(pop1),
  "sum(age groups) == All Ages in pop5" = check_all_ages_sum(pop5),
  "Births - Deaths == Nat. Inc. in components" = check_births_deaths(components)
)

# ---- save ------------------------------------------------------------------

usethis::use_data(pop1, overwrite = TRUE)
usethis::use_data(pop5, overwrite = TRUE)
usethis::use_data(components, overwrite = TRUE)
