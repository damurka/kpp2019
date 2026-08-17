# Changelog

## kpp2019 (development version)

- Initial CRAN submission.
- Rebuilt `pop1`, `pop5` and `components` from the source KNBS workbook
  via a reproducible script (`data-raw/prepare-data.R`). This corrects
  several errors in `pop1` inherited from the previous data-preparation
  process: incorrect/misaligned figures for Kisumu (2031-2035), and
  swapped Male/Total values in Wajir’s “All Ages” rows for several
  years. `pop1` now has 41,472 rows (was 41,424) because Kisumu’s
  previously-dropped age group is now included.
- Fixed a data-entry error in the source workbook itself: Busia’s annual
  age-distribution sheet had the wrong figure for age 80+, Female, 2030
  (it disagreed with the county’s own 5-year checkpoint table, and with
  Male + Female == Total). `data-raw/prepare-data.R` now cross-checks
  the annual tables against the checkpoint table at every year they
  share and substitutes the checkpoint’s figure on mismatch, which also
  corrects the four years (2026-2029) interpolated from the bad 2030
  value. The script asserts `Male + Female == Total`,
  `sum(age groups) == "All Ages"`, and `Births - Deaths == Nat. Inc.` on
  every build so a similar defect in a future source update is caught
  rather than silently shipped.
- `pop1$pop`, `pop5$pop` and `components$value` are now kept at the full
  decimal precision published by KNBS, rather than rounded to whole
  numbers. Round these columns yourself if whole-person/whole-unit
  figures are needed.
- Corrected the `components` documentation: Births, Deaths, Nat.
  Inc. and Net Mig. were incorrectly documented as being “in thousands”
  (e.g. Kenya’s 2020-25 Births figure is `6,404,408`, a headcount, not
  thousands).
- Added `tests/testthat/test-data-integrity.R`, covering the invariants
  used to validate this release’s data against the source workbook (no
  missing/duplicate rows, Male + Female == Total, sum of age groups ==
  “All Ages”, Births - Deaths == Nat. Inc., and pop1/pop5 agreement at
  shared checkpoint years) so a future data refresh that reintroduces a
  similar defect fails CI instead of shipping silently.
- Guarded the `ggplot2`/`dplyr` example code in `pop1`, `pop5` and
  `components` with
  [`requireNamespace()`](https://rdrr.io/r/base/ns-load.html) checks,
  since both are only in `Suggests`; the examples previously errored
  under CRAN’s “suggests not available” check flavour.
- Trimmed a duplicate entry from `DESCRIPTION`’s `URL` field
  (`http://kpp2019.damurka.com/` duplicated the `https://` entry already
  listed).
