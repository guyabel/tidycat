usethis::use_cran_badge()
usethis::use_lifecycle_badge(stage = "superseded")
# usethis::use_pipe()
# usethis::use_tibble()
# usethis::use_news_md()
usethis::use_build_ignore(
  c("build_package.R", "hex",
     "README")
)

usethis::create_github_token()
gitcreds::gitcreds_set()
usethis::use_github()
usethis::git_sitrep()
usethis::git_vaccinate()

usethis::use_github_actions()
usethis::git_remotes()
usethis::gh_token_help()

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
gitcreds::gitcreds_set()
usethis::use_github(protocol = "https", authtoken = GITHUB_PAT)
usethis::use_github_links()

usethis::use_github_action("check-standard.yaml")
https://raw.githubusercontent.com/r-lib/actions/master/examples/check-standard.yaml
usethis::use_github_action_check_standard()

roxygen2::roxygenise()

devtools::check()
devtools::build()

file.show("NEWS.md")

usethis::use_pkgdown()
pkgdown::build_site(run_dont_run = TRUE)
pkgdown::build_reference()

usethis::use_spell_check()

