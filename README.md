
<!-- README.md is generated from README.Rmd. Please edit that file -->

# kpp2019: Kenya Population Projections <a href="https://kpp2019.damurka.com"><img src="man/figures/logo.png" align="right" height="138" alt = ""/></a>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/kpp2019)](https://CRAN.R-project.org/package=kpp2019)
[![R-CMD-check](https://github.com/damurka/kpp2019/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/damurka/kpp2019/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/damurka/kpp2019/graph/badge.svg)](https://app.codecov.io/gh/damurka/kpp2019)
<!-- badges: end -->

## Overview

The `kpp2019` package provides key dataset for population projections in
Kenya from 2020 to 2045. The data are based on the **2019 Kenya
Population and Housing Census** and subsequent projections made by the
**Kenya National Bureau of Statistics (KNBS)**. This package is
developed independently by a third party to make this valuable data more
accessible for researchers, policy-makers, and planners who are
interested in Kenya’s demographic trends over the next few decades.

The data presented in this package offer insights into population
growth, demographic composition, and migration patterns across Kenyan
counties, which are essential for designing policies, allocating
resources, and monitoring national development goals.

## Disclaimer

This package was developed independently and is not affiliated with or
endorsed by the Kenya National Bureau of Statistics (KNBS) or any other
governmental organization. The data provided here are based on publicly
available projections published by KNBS. For more detailed information
and official documentation, please refer to the original source provided
in the “Data Sources” section below.

## Installation

You can install the development version of kpp2019 from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("damurka/kpp2019")
```

## Usage

After installation, you can load the datasets and start exploring
Kenya’s population projections.

``` r
# Load the package
library(kpp2019)

# Load a dataset
data("pop1")

# View the first few rows
head(pop1)
#>   county age year gender     pop
#> 1  Kenya 0-4 2020   Male 3123737
#> 2  Kenya 0-4 2020 Female 3156282
#> 3  Kenya 0-4 2020  Total 6280019
#> 4  Kenya 0-4 2021   Male 3143314
#> 5  Kenya 0-4 2021 Female 3147353
#> 6  Kenya 0-4 2021  Total 6290667
```

## Dataset

### 1. `pop1`: Base and Projected Age Distributions in Kenya (2020-2035, Annual Increments)

This dataset provides annual population projections by county, age
group, and gender for the period 2020 to 2035.

### 2. `pop5`: Base and Projected Age Distributions in Kenya (2020-2045, Five-Year Increments)

This dataset provides population projections for every five years
between 2020 and 2045.

### 3. `components`: Components of Population Change in Kenya (2020-2045)

This dataset contains the components of population change over five-year
periods, including births, deaths, natural increase, and net migration.
It also includes rates such as crude birth rate (CBR) and crude death
rate (CDR).

## Data Sources

The data used in this package comes from the **Kenya National Bureau of
Statistics (KNBS)**, specifically the **2019 Kenya Population and
Housing Census** and the related population projections. The original
datasets and reports can be accessed from the KNBS website: - [2019
Kenya Population and Housing Census Analytical Report on Population
Projections](https://www.knbs.or.ke/wp-content/uploads/2023/09/2019-Kenya-population-and-Housing-Census-Analytical-Report-on-Population-Projections.pdf)

## License

This package and its data are licensed under the Creative Commons
Attribution 4.0 International License. While the data are sourced from
KNBS, this package was developed independently, and appropriate
attribution should be given when using the data.

## Contributing

If you’d like to contribute to the development of kpp2019, please read
[these guidelines](https://kpp2019.damurka.com/CONTRIBUTING.html).

Please note that the kpp2019 project is released with a [Contributor
Code of Conduct](https://kpp2019.damurka.com/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its terms.
