# Source: https://doi.org/10.5281/zenodo.7904761

steam_raw <- read.csv(
  "data-raw/steam.csv",
  stringsAsFactors = FALSE)

steam_games <- steam_raw[c(
  "appid", "name", "release_date", "genres", "price",
  "positive_ratings", "negative_ratings")]

steam_games$release_date <- as.Date(steam_games$release_date)

steam_games$total_reviews <-
  steam_games$positive_ratings + steam_games$negative_ratings

steam_games$positive_percent <- with(
  steam_games,
  ifelse(
    total_reviews > 0,
    100 * positive_ratings / total_reviews,
    NA_real_))

usethis::use_data(steam_games, overwrite = TRUE)

