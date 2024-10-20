#' Base and Projected Age Distributions in Kenya (2020-2045, Five-Year Increments)
#'
#' This dataset provides base and projected population distributions by county,
#' age group, gender, and year for Kenya from 2020 to 2045 in **five-year increments**.
#' It includes population estimates derived from the 2019 Kenya Population and Housing Census
#' and subsequent projections by the Kenya National Bureau of Statistics (KNBS).
#'
#' @format A data frame with 15,552 rows and 5 variables:
#' \describe{
#'   \item{county}{Name of the county in Kenya}
#'   \item{age}{Age group in 5-year intervals (e.g., "0-4", "5-9", ..., "80+")}
#'   \item{year}{Year of the population estimate}
#'   \item{gender}{Gender category ("Male", "Female", or "Total")}
#'   \item{pop}{Estimated population count for the specified county, age group, gender, and year}
#' }
#'
#' @details
#' The `pop5` dataset can be used to analyse demographic trends, plan resource allocation,
#' and study population dynamics in Kenya over the specified years. The projections
#' take into account factors such as fertility rates, mortality rates, and migration
#' patterns. The age groups are provided in 5-year intervals, and the population
#' estimates are available in five-year increments from 2020 to 2045.
#'
#' **Note:**
#' - The "Total" gender category represents the combined population of both males and females.
#' - The "All Ages" age category represents the combined ages of all age groups.
#'
#' @source
#' Kenya National Bureau of Statistics (2023). *2019 Kenya Population and Housing Census Analytical Report on Population Projections*. Retrieved from [knbs.or.ke](https://www.knbs.or.ke/wp-content/uploads/2023/09/2019-Kenya-population-and-Housing-Census-Analytical-Report-on-Population-Projections.pdf).
#'
#' @examples
#' data(pop5)
#' head(pop5)
#' summary(pop5)
#'
#' # Example: Plotting the population distribution for Mombasa County in 2025
#' library(ggplot2)
#' library(dplyr)
#' mombasa_2025 <- pop5 %>%
#'   filter(county == "Mombasa", year == 2025, gender == "Total", age != 'All Ages')
#' ggplot(mombasa_2025, aes(x = age, y = pop)) +
#'   geom_bar(stat = "identity") +
#'   labs(
#'     title = "Population Distribution in Mombasa County (2025)",
#'     x = "Age Group",
#'     y = "Population"
#'   ) +
#'   theme_minimal()
"pop5"
