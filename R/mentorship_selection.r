library(dplyr)
library(readr)

mentorship_data <- read_csv(
  "registration_analysis_private/output/mentorship_data/mentorship_list.csv"
)
submissions_data <- read_csv(
  "registration_analysis_private/data/all-submissions-2025-10-01T09-59-27.csv"
)

students_with_both_quizzes <- submissions_data %>%
  filter(Module %in% c("md-01-quiz", "md-02-quiz")) %>%
  group_by(`GitHub Username`) %>%
  summarise(quizzes_completed = n(), .groups = 'drop') %>%
  filter(quizzes_completed == 2) %>%
  pull(`GitHub Username`)

mentorship_intersection <- mentorship_data %>%
  filter(github_username %in% students_with_both_quizzes)

mentors_maintained_own_use <- mentorship_intersection %>%
  filter(
    (prog_r %in%
      c("maintained", "own_use") |
      prog_general %in% c("maintained", "own_use")) &
      (mentorship_interest == "mentor" |
        prog_r %in% c("maintained", "own_use") |
        prog_general %in% c("maintained", "own_use"))
  )

mentors_maintained_own_use_few_lines <- mentorship_intersection %>%
  filter(
    (prog_r %in%
      c("maintained", "own_use", "few_lines") |
      prog_general %in% c("maintained", "own_use", "few_lines")) &
      (mentorship_interest == "mentor" |
        prog_r %in% c("maintained", "own_use", "few_lines") |
        prog_general %in% c("maintained", "own_use", "few_lines"))
  )

write_csv(
  mentors_maintained_own_use,
  "registration_analysis_private/output/mentorship_selection/mentors_maintained_own_use.csv"
)
write_csv(
  mentors_maintained_own_use_few_lines,
  "registration_analysis_private/output/mentorship_selection/mentors_maintained_own_use_few_lines.csv"
)

cat("Mentorship selection completed!\n")
cat("Students with both quizzes:", length(students_with_both_quizzes), "\n")
cat("Mentorship data intersected:", nrow(mentorship_intersection), "\n")
cat("Mentors (maintained+own_use):", nrow(mentors_maintained_own_use), "\n")
cat(
  "Mentors (maintained+own_use+few_lines):",
  nrow(mentors_maintained_own_use_few_lines),
  "\n"
)
