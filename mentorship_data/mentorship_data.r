# Load required libraries
library(tidyverse)
library(robotoolbox)
library(readxl)
library(labelled)
library(here)

form_id <- "ashaEDvw4ZLwGi9bqXGeqb"
form_file <- "../data/registration_form.xlsx"
roster_url <- "https://raw.githubusercontent.com/ds4owd-dev/admin/refs/heads/main/data/final/tbl-01-ds4owd-participant-roster.csv?token=GHSAT0AAAAAADFER3QYR7YNXPZU2WMUF2AE2G322KA"

# fetch data from Kobo with robotoolbox
raw_data <- kobo_data(x = form_id,
                      all_versions = TRUE)

# read in questionnaire and labels from XLS form
questionnaire <- read_xlsx(form_file,
                           sheet = "survey")

label_dict <- read_xlsx(form_file,
                        sheet = "choices")

# read participant roster
team_users <- c("massarin", "larnsce", "seawaR",
                "galacticasparagus", "rainbow-train", "betadetective")

participant_roster <- read_csv(file = roster_url) |>
  filter(!github_username %in% team_users)

# data processing
kobo_clean <- raw_data |>
  mutate(github_username = case_when(
    github_username == "@FarahArbi" ~ "FarahArbi",
    github_username == "Cecilia2020-ux!" ~ "Cecilia2020-ux",
    github_username == "https://github.com/squiebble" ~ "squiebble",
    github_username == "odehcaleb/my-space" ~ "odehcaleb",
    github_username == "https://github.com/FundileK" ~ "FundileK",
    github_username == "https://github.com/stacianordin" ~ "stacianordin",
    github_username == "https://github.com/Fadilah-hub" ~ "Fadilah-hub",
    github_username == "https://github.com/adesijivictoria" ~ "adesijivictoria",
    github_username == "wendiegrm@gmail.com" ~ "WondiberNega",
    github_username == "mada Mcnight" ~ "Madalitsokanache",
    github_username == "Bensi4-first" ~ "Bensi4",
    github_username == "Mundrugo Sunday James" ~ "munjame",
    github_username == "munashechiwanza" ~ "chiwanzamunashe",
    github_username == "rebecca-lk" ~ "Rebecca-LK",
    github_username == "collins1125" ~ "Collins1125",
    github_username == "https://github.com/Andrema123-GIT" ~ "Andrema123-GIT",
    github_username == "Gyamphie" ~ "Djamphie",
    github_username == "kaitlingpeck" ~ "kpeckEREF",
    github_username == "kunzrp@gmail.com" ~ "kunzrp",
    github_username == "alazarnegash1" ~ "alazarnegash-horecha",
    github_username == "https://github.com/" & first_name == "Hope" ~ "HopeChilunga",
    github_username == "Collo001" ~ "Collo2004",
    github_username == "https://github.com/imegit" ~ "imegit",
    github_username == "Promise-707" ~ "Promise707-lab",
    github_username == "Assumpta Obianuju Ezeaba" ~ "Assumpta-hub",
    github_username == "faiza.audri@northsouth.edu" ~ "faizaaudri03",
    github_username == "AnalystKemi (https://github.com/AnalystKemi)" ~ "AnalystKemi",
    github_username == "https://github.com/astute2011/" ~ "astute2011",
    github_username == "phumlilemafuze@gamail.com" ~ "PhumlileAmanda",
    github_username == "paul" ~ "tangqiqing",
    github_username == "Harlod Zaunda" ~ "Harlod-max",
    github_username == "ruraldevsolutions" ~ "yousefia601",
    TRUE ~ github_username)) |>
  mutate(email = tolower(email)) |>
  mutate(email = case_when(
    email == "ayousefi@iut.ac.ir" ~ "yousefia601@yahoo.com",
    TRUE ~ email
  )) |>
  mutate(github_username = tolower(github_username)) |>
  distinct(github_username, .keep_all = TRUE) |>
  select(github_username,
         email,
         first_name,
         country_residence,
         organisation_name,
         prog_r,
         prog_general,
         mentorship_interest) |>
  right_join(participant_roster |>
               select(github_username),
             by = "github_username")

write_csv(kobo_clean,
          file = here::here("mentorship_data/output/mentorship_list.csv"))
