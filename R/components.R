#' Components of Population Change in Kenya (2020-2045)
#'
#' This dataset provides components of population change in Kenya over several 5-year projection periods from 2020 to 2045. The dataset includes key demographic components such as births, deaths, natural increase, and migration, along with related population rates such as crude birth rate, crude death rate, natural increase rate, and net migration rate. The data is structured for each projection period.
#'
#' @format A data frame with 1,920 rows and 4 variables:
#' \describe{
#'   \item{county}{Name of the county (factor).}
#'   \item{component}{The demographic component being measured (factor). Possible values include:
#'   \describe{
#'     \item{Births}{The total number of births during the projection period.}
#'     \item{Deaths}{The total number of deaths during the projection period.}
#'     \item{Nat. Inc.}{Natural Increase: the difference between births and deaths during the projection period.}
#'     \item{Net Mig.}{Net Migration: the net number of people entering or leaving Kenya during the projection period (immigrants minus emigrants).}
#'     \item{CBR}{Crude Birth Rate: the number of births per 1,000 population per year during the projection period.}
#'     \item{CDR}{Crude Death Rate: the number of deaths per 1,000 population per year during the projection period.}
#'     \item{CNIR}{Crude Natural Increase Rate: the difference between the crude birth rate and crude death rate, representing natural population growth per 1,000 population per year.}
#'     \item{CNMR}{Crude Net Migration Rate: the net migration rate, representing the net number of migrants per 1,000 population per year.}
#'   }}
#'   \item{year}{The 5-year projection period (factor). Possible values are "2020-25", "2026-30", "2031-35", "2036-40", and "2041-45".}
#'   \item{value}{The numeric value associated with the component for the specific projection period (numeric).}
#' }
#'
#' @details
#' This dataset captures various components of population change for Kenya from 2020 to 2045. It allows users to analyze demographic changes over time, including the impacts of births, deaths, migration, and natural increase on population size. The rates, such as the crude birth rate (CBR) and crude death rate (CDR), provide insights into demographic trends per 1,000 population.
#'
#' **Components Explained**:
#' - **Births**: Total births during the projection period (in thousands).
#' - **Deaths**: Total deaths during the projection period (in thousands).
#' - **Natural Increase (Nat. Inc.)**: Difference between births and deaths (in thousands).
#' - **Net Migration (Net Mig.)**: Net migration (immigrants minus emigrants) during the projection period (in thousands).
#' - **Crude Birth Rate (CBR)**: Births per 1,000 people per year.
#' - **Crude Death Rate (CDR)**: Deaths per 1,000 people per year.
#' - **Crude Natural Increase Rate (CNIR)**: Natural increase per 1,000 people per year (CBR minus CDR).
#' - **Crude Net Migration Rate (CNMR)**: Net migration per 1,000 people per year.
#'
#' @source
#' Kenya National Bureau of Statistics (2023). *2019 Kenya Population and Housing Census Analytical Report on Population Projections*.
#' Retrieved from [knbs.or.ke](https://www.knbs.or.ke/wp-content/uploads/2023/09/2019-Kenya-population-and-Housing-Census-Analytical-Report-on-Population-Projections.pdf).
#'
#' @examples
#' data(components)
#' head(components)
#' summary(components)
#'
#' # Example: Plot the number of births over the projection periods for Kenya
#' library(ggplot2)
#' library(dplyr)
#' births <- components %>%
#'   filter(component == "Births", county == 'Kenya')
#' ggplot(births, aes(x = factor(year, ordered = TRUE), y = value, group = county)) +
#'   geom_line() +
#'   geom_point() +
#'   labs(
#'     title = "Projected Births in Kenya (2020-2045)",
#'     x = "Projection Period",
#'     y = "Number of Births"
#'   ) +
#'   theme_minimal()
"components"
