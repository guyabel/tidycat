#' Expand broom::tidy() Outputs for Categorical Parameter Estimates
#'
#' Create additional columns in a tidy model output (such as \link[broom:tidy.lm]{broom::tidy.lm()}) to allow for easier control when plotting categorical parameter estimates.
#'
#' @param d A data frame \link[tibble:tibble]{tibble::tibble()} output from \link[broom:tidy.lm]{broom::tidy.lm()}; with one row for each term in the regression, including column `term`
#' @param m A model object, created using a function such as \link[stats:lm]{stats::lm()}
#' @param exclude_reference Logical indicating to include additional rows in output for reference categories, obtained from \link[stats:dummy.coef]{stats::dummy.coef()}. Defaults to `TRUE`
#' @param reference_label Character string. When used will create an additional column in output with labels to indicate if terms correspond to reference categories or not.
#' @param exponentiate Logical indicating whether or not the results in \link[broom:tidy.lm]{broom::tidy.lm()} are exponentiated. Defaults to `FALSE`.
#'
#' @return Expanded \link[tibble:tibble]{tibble::tibble()} from the version passed to `d` including additional columns:
#' \item{variable}{The name of the variable that the regression term belongs to.}
#' \item{level}{The level of the categorical variable that the regression term belongs to. Will be an empty string for numeric variables.}
#' \item{effect}{The type of term (`main` or `interaction`)}
#' \item{reference}{The type of term (`reference` or `non-reference`) with label passed from `reference_label`. If `reference_label` is set `NULL` (default) will not be created.}
#' In addition, extra rows will be added, if `exclude_reference` is set to `FALSE` for the reference categories, obtained from \link[stats:dummy.coef]{stats::dummy.coef()}
#' @seealso \link[broom:tidy.lm]{broom::tidy.lm()}
#'
#' @export
#' @importFrom magrittr "%>%"
#' @import utils
#'
#' @examples
#' # strip ordering in factors (currently ordered factor not supported)
#' library(dplyr)
#' library(broom)
#'
#' m0 <- esoph %>%
#'   mutate_if(is.factor, ~factor(., ordered = FALSE)) %>%
#'   glm(cbind(ncases, ncontrols) ~ agegp + tobgp * alcgp, data = .,
#'         family = binomial())
#' # tidy
#' tidy(m0)
#'
#' # add further columns to tidy output to help manage categorical variables
#' m0 %>%
#'  tidy() %>%
#'  tidy_categorical(m = m0)
#'
#' # include reference categories and column to indicate the additional terms
#' m0 %>%
#'  tidy() %>%
#'  tidy_categorical(m = m0, exclude_reference = FALSE, reference_label = "Reference")
#'
#' # coefficient plots
#' d0 <- m0 %>%
#'   tidy(conf.int = TRUE) %>%
#'   tidy_categorical(m = m0, exclude_reference = FALSE, reference_label = "Baseline") %>%
#'   # drop the intercept term
#'   slice(-1)
#' d0
#'
#' # typical coefficient plot
#' library(ggplot2)
#' library(tidyr)
#' ggplot(data = d0 %>% drop_na(),
#'        mapping = aes(x = term, y = estimate,
#'                      ymin = conf.low, ymax = conf.high)) +
#'   coord_flip() +
#'   geom_hline(yintercept = 0, linetype = "dashed") +
#'   geom_pointrange()
#'
#' # enhanced coefficient plot using additional columns from tidy_categroical and ggforce::facet_row()
#' library(ggforce)
#' ggplot(data = d0,
#'        mapping = aes(x = level, colour = reference,
#'                      y = estimate, ymin = conf.low, ymax = conf.high)) +
#'   facet_row(facets = vars(variable), scales = "free_x", space = "free") +
#'   geom_hline(yintercept = 0, linetype = "dashed") +
#'   geom_pointrange() +
#'   theme(axis.text.x = element_text(angle = 45, hjust = 1))
tidy_categorical <- function(d, m, exclude_reference = TRUE, reference_label = NULL,
                             exponentiate = FALSE){
  m %>%
    stats::dummy.coef() %>%
    base::unlist() %>%
    tibble::enframe(value = "est") %>%
    dplyr::mutate(
      variable = stringr::str_extract(string = name, pattern = factor_regex(m)),
      level = stringr::str_remove(string = name, pattern = factor_regex(m)),
      level = stringr::str_remove(string = level, pattern = "^[.]"),
      level = base::ifelse(variable == level, "", level),
      level = forcats::fct_inorder(level),
      effect = base::ifelse(test = stringr::str_detect(string = variable, pattern = ":"),
                            yes = "interaction", no = "main"),
      n = base::ifelse(test = est == 0, yes = 0, no = 1),
      n = base::cumsum(n),
      n = base::ifelse(test = n == dplyr::lag(n), yes = NA, no = n),
      n = base::ifelse(test = dplyr::row_number() == 1, yes = 1, no = n),
      term = d$term[n]) %>%
    dplyr::select(-n, -name, -est) %>%
    dplyr::left_join(d, by = "term") %>%
    dplyr::mutate_if(is.numeric, ~ifelse(is.na(.), ifelse(exponentiate, 1, 0), .)) %>%
    dplyr::select(-variable, -level, -effect, dplyr::everything(), variable, level, effect) %>%
    {if(!is.null(reference_label)) dplyr::mutate(., reference = base::ifelse(test = base::is.na(term), yes = reference_label, no = paste0("Non-",reference_label))) else .} %>%
    {if(exclude_reference) dplyr::filter(., !base::is.na(term)) else .}
}


#
# tidy_type <- function(x){
#   m0 <- x %>%
#     filter(effect == "main") %>%
#     mutate(type = case_when(effect == "main" & level != "" ~ "factor",
#                             effect == "main" & level == "" ~ "numeric"))
#
#   m1 <- m0 %>%
#     select(variable, type) %>%
#     distinct()
#
#   i0 <- x %>%
#     filter(effect == "interaction")
#
#   i1 <- i0 %>%
#     select(variable) %>%
#     distinct() %>%
#     rename(main = variable) %>%
#     mutate(interaction = main) %>%
#     separate_rows(main, sep = ":") %>%
#     left_join(m1, by = c("main" = "variable")) %>%
#     group_by(interaction) %>%
#     summarise(type = paste0(type, collapse = ":")) %>%
#     rename(variable = interaction) %>%
#     left_join(i0, by = "variable")
#
#   m0 %>%
#     bind_rows(i1)
# }
#
# tidy_term <- function(x){
#   m0 <- x %>%
#     filter(effect == "main") %>%
#     mutate(term = case_when(type == "numeric" ~ variable,
#                             type == "factor" ~ paste0(variable, level)))
#
#   m1 <- m0 %>%
#     select(variable, type, term) %>%
#     distinct()
#
#   i0 <- x %>%
#     filter(effect == "interaction")
#
#   i1 <-
#     i0 %>%
#     select(variable) %>%
#     distinct() %>%
#     rename(main = variable) %>%
#     mutate(interaction = main) %>%
#     separate_rows(main, sep = ":") %>%
#     left_join(m1, by = c("main" = "variable")) %>%
#     select(-main) %>%
#     distinct()
#   group_by(interaction) %>%
#     summarise(type = paste0(term, collapse = ":")) %>%
#     rename(variable = interaction) %>%
#     left_join(i0, by = "variable")
#
#   i1 <-
#     i0 %>%
#     select(variable, level) %>%
#     # rename(main = variable) %>%
#     mutate(interaction = variable) %>%
#     separate_rows(variable, sep = ":") %>%
#     separate_rows(level, sep = ":") %>%
#     separate_rows(type, sep = ":") %>%
#     distinct()
#   %>%
#
#     left_join(m1, by = c("main" = "variable")) %>%
#     group_by(interaction) %>%
#     summarise(type = paste0(type, collapse = ":")) %>%
#     rename(variable = interaction) %>%
#     left_join(i0, by = "variable")
#
#   m0 %>%
#     bind_rows(i1)
# }

