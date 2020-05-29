#' Generate Regular Expression to Detect Factors
#'
#' Primarily developed for use within \link[tidycat:tidy_categorical]{tidycat::tidy_categorical()}
#'
#' @param m A model object, created using a function such as \link[stats:lm]{stats::lm()}
#' @param at_start Logical indicating whether or not to include `^` in the regular expression to begin search at start of string
#'
#' @return A character string for use as a regular expression.
#' @author Guy J. Abel
#'
#' @export
#' @importFrom magrittr "%>%"
#' @import utils
#'
#' @examples
#' m0 <- lm(formula = mpg ~ disp + as.factor(am)*as.factor(vs), data = mtcars)
#' factor_regex(m = m0)
factor_regex <- function(m, at_start = TRUE){
  i <- m %>%
    stats::terms() %>%
    base::attr("intercept")

  m %>%
    stats::terms() %>%
    base::attr("term.labels") %>%
    base::rev() %>%
    c(base::switch(i == 1, "(Intercept)", NULL)) %>%
    base::paste0(collapse = ifelse(at_start, "|^", "|")) %>%
    stringr::str_replace_all(pattern = "[(]", replacement = "[(]") %>%
    stringr::str_replace_all(pattern = "[)]", replacement = "[)]") %>%
    stringr::str_replace_all(pattern = "[.]", replacement = "[.]") %>%
    base::paste0(ifelse(at_start, "(^", "("), ., ")")
}
