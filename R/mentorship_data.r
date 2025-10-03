# Load required libraries
library(tidyverse)
library(robotoolbox)
library(readxl)
library(labelled)
library(here)

form_id <- "ashaEDvw4ZLwGi9bqXGeqb"
form_file <- "data/registration_form.xlsx"

# Build roster URL with token from environment variable
github_token <- Sys.getenv("GITHUB_PAT")
if (github_token == "") {
  stop("GITHUB_PAT environment variable not set. Please add it to your .Renviron file.")
}

roster_url <- paste0(
  "https://raw.githubusercontent.com/ds4owd-dev/admin/refs/heads/main/data/final/tbl-01-ds4owd-participant-roster.csv?token=",
  github_token
)

# fetch data from Kobo with robotoolbox
raw_data <- kobo_data(x = form_id, all_versions = TRUE)

# read in questionnaire and labels from XLS form
questionnaire <- read_xlsx(form_file, sheet = "survey")

label_dict <- read_xlsx(form_file, sheet = "choices")

# read username and email mappings
username_mappings <- read_csv(
  here::here("registration_analysis_private/data/username_mappings.csv"),
  show_col_types = FALSE
)

email_mappings <- read_csv(
  here::here("registration_analysis_private/data/email_mappings.csv"),
  show_col_types = FALSE
)

# read participant roster and team users
team_users <- read_csv(
  here::here("registration_analysis_private/data/team_users.csv"),
  show_col_types = FALSE
) |>
  pull(github_username)

participant_roster <- read_csv(file = roster_url) |>
  filter(!github_username %in% team_users)

# data processing
kobo_clean <- raw_data |>
  # Apply username mappings
  left_join(username_mappings, by = c("github_username" = "original_username")) |>
  mutate(github_username = coalesce(corrected_username, github_username)) |>
  select(-corrected_username) |>
  # Handle special case for Hope
  mutate(github_username = if_else(
    github_username == "https://github.com/" & first_name == "Hope",
    "HopeChilunga",
    github_username
  )) |>
  # Apply email mappings
  mutate(email = tolower(email)) |>
  left_join(email_mappings, by = c("email" = "original_email")) |>
  mutate(email = coalesce(corrected_email, email)) |>
  select(-corrected_email) |>
  mutate(github_username = tolower(github_username)) |>
  distinct(github_username, .keep_all = TRUE) |>
  select(
    github_username,
    email,
    first_name,
    country_residence,
    organisation_name,
    prog_r,
    prog_general,
    mentorship_interest
  ) |>
  right_join(
    participant_roster |>
      select(github_username),
    by = "github_username"
  )

write_csv(
  kobo_clean,
  file = here::here(
    "registration_analysis_private/output/mentorship_data/mentorship_list.csv"
  )
)
