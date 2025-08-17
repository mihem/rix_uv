library(rix)

my_token <- gitcreds::gitcreds_get()$password
Sys.setenv(GITHUB_PAT = my_token)

rix(
  date = "2025-08-11",
  r_pkgs = c(
    "languageserver",
    "tidyverse"
  ),
  system_pkgs = c("uv"),
  ide = "none",
  project_path = ".",
  overwrite = TRUE,
  print = TRUE
)

