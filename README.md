
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tidycat

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/tidycat)](https://CRAN.R-project.org/package=tidycat)
[![CRAN RStudio mirror
downloads](https://cranlogs.r-pkg.org/badges/grand-total/tidycat?color=blue)](https://r-pkg.org/pkg/tidycat)
[![Lifecycle:
superseded](https://img.shields.io/badge/lifecycle-superseded-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html#superseded)
[![R-CMD-check](https://github.com/guyabel/tidycat/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/guyabel/tidycat/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

<!-- <img src='./man/figures/logo.png' align="right" height="139" /> -->

## Introduction

The `tidycat` package includes the `tidy_categorical()` function to
expand `broom::tidy()` outputs for categorical parameter estimates.

See the [pkgdown site](http://guyabel.github.io/tidycat/) for full
details.

## Installation

You can install the released version of tidycat from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("tidycat")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("guyabel/tidycat")
```

## Limitations

The `tidy_categorical()` function will probably not work as expected for
non-default contrasts such as `contr.helmert()` and when one or more
model parameters are rank deficient. It also only supports a limited
range of models; `lm()` or `glm()` should be fine. For more complex
cases, or an alternative method to create great coefficient plots, see
the `ggcoef_model()` function in the
[GGally](https://ggobi.github.io/ggally/reference/ggcoef_model.html)
package, which went through a major upgrade around the same time as I
developed tidycat.

## Documentation

For full documentation, see the package vignette: [The tidycat package:
expand broom::tidy() output for categorical parameter
estimates](https://guyabel.github.io/tidycat/articles/tidycat.html)

## Hello World

The `tidy()` function in the broom package takes the messy output of
built-in functions in R, such as `lm()`, and turns them into tidy data
frames.

``` r
library(dplyr)
library(broom)

m1 <- mtcars %>%
  mutate(transmission = recode_factor(am, `0` = "automatic", `1` = "manual")) %>%
  lm(mpg ~ as.factor(cyl) + transmission + wt *  as.factor(cyl), data = .)

tidy(m1)
#> # A tibble: 7 × 5
#>   term               estimate std.error statistic       p.value
#>   <chr>                 <dbl>     <dbl>     <dbl>         <dbl>
#> 1 (Intercept)          41.5        4.54     9.14  0.00000000190
#> 2 as.factor(cyl)6      -8.66      10.4     -0.836 0.411        
#> 3 as.factor(cyl)8     -16.9        5.27    -3.20  0.00374      
#> 4 transmissionmanual   -0.902      1.51    -0.595 0.557        
#> 5 wt                   -6.19       1.65    -3.75  0.000937     
#> 6 as.factor(cyl)6:wt    2.12       3.40     0.625 0.538        
#> 7 as.factor(cyl)8:wt    3.84       1.77     2.17  0.0399
```

The `tidy_categorical()` function adds

- further columns (`variable`, `level` and `effect`) to the
  `broom::tidy()` output to help manage categorical variables
- further rows for reference category terms and a column to indicate
  their location (`reference`) when setting `include_reference = TRUE`
  (default)

It requires two inputs

- a data frame `d` of parameter estimates from a model from
  `broom::tidy()`
- the corresponding model object `m` passed to `broom::tidy()`

For example:

``` r
library(tidycat)
d1 <- m1 %>%
  tidy(conf.int = TRUE) %>%
  tidy_categorical(m = m1)
d1 %>%
  select(-(3:5))
#> # A tibble: 10 × 8
#>    term               estimate conf.low conf.high variable  level effect refer…¹
#>    <chr>                 <dbl>    <dbl>     <dbl> <chr>     <fct> <chr>  <chr>  
#>  1 (Intercept)          41.5     32.1       50.8  (Interce… (Int… main   Non-Ba…
#>  2 <NA>                  0        0          0    as.facto… 4     main   Baseli…
#>  3 as.factor(cyl)6      -8.66   -30.0       12.7  as.facto… 6     main   Non-Ba…
#>  4 as.factor(cyl)8     -16.9    -27.7       -6.00 as.facto… 8     main   Non-Ba…
#>  5 <NA>                  0        0          0    transmis… auto… main   Baseli…
#>  6 transmissionmanual   -0.902   -4.02       2.22 transmis… manu… main   Non-Ba…
#>  7 wt                   -6.19    -9.59      -2.79 wt        wt    main   Non-Ba…
#>  8 <NA>                  0        0          0    as.facto… 4     inter… Baseli…
#>  9 as.factor(cyl)6:wt    2.12    -4.87       9.12 as.facto… 6     inter… Non-Ba…
#> 10 as.factor(cyl)8:wt    3.84     0.192      7.50 as.facto… 8     inter… Non-Ba…
#> # … with abbreviated variable name ¹​reference
```

The expanded data frame from `tidy_categorical()` of parameter estimates
can be particularly useful for creating coefficient plots, allowing:

- grouping terms from the same categorical variable from the additional
  columns.
- inclusion of reference categories in a coefficient plot from the
  additional rows, allowing the reader to better grasp the meaning of
  the parameter estimates in each categorical variable.

For example:

``` r
library(forcats)
library(ggplot2)
library(ggforce)

d1 %>%
  slice(-1) %>%
  mutate(variable = fct_inorder(variable)) %>%
  ggplot(mapping = aes(x = level, y = estimate, colour = reference,
                       ymin = conf.low, ymax = conf.high)) +
  facet_row(facets = "variable", scales = "free_x", space = "free") +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_pointrange()
```

<img src="https://raw.githubusercontent.com/guyabel/tidycat/master/README-files/unnamed-chunk-4-1.png" width="100%" />
