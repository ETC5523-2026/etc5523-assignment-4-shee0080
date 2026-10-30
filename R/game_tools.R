#' Filter historical Steam games
#'
#' Keep games within a budget and review-count threshold. A game can have
#' several semicolon-separated genres; matching any selected genre is enough,
#' and each game is returned only once.
#'
#' @param data A data frame with the columns in [steam_games].
#' @param genres Character vector of genre labels. NULL includes every genre;
#'   character(0) returns no games.
#' @param max_price One non-negative historical price in GBP. Inf includes
#'   all prices.
#' @param min_reviews One finite, non-negative minimum review count.
#' @return A data frame with the matching rows and original columns.
#' @importFrom dplyr filter
#' @importFrom rlang .data .env
#' @export
#' @examples
#' games <- filter_games(steam_games, "Action", 20, 100)
#' utils::head(games, 3)
filter_games <- function(data, genres = NULL, max_price = Inf,
                         min_reviews = 0) {
  required <- c("genres", "price", "total_reviews")
  if (!is.data.frame(data) || !all(required %in% names(data))) {
    stop("data must contain genres, price and total_reviews.", call. = FALSE)
  }
  if (!is.numeric(max_price) || length(max_price) != 1L ||
      is.na(max_price) || max_price < 0) {
    stop("max_price must be one non-negative number.", call. = FALSE)
  }
  if (!is.numeric(min_reviews) || length(min_reviews) != 1L ||
      !is.finite(min_reviews) || min_reviews < 0) {
    stop("min_reviews must be one finite non-negative number.", call. = FALSE)
  }
  if (!is.null(genres) && (!is.character(genres) || anyNA(genres))) {
    stop("genres must be NULL or a character vector without missing values.",
         call. = FALSE)
  }

  # Steam stores several genres in one cell. Match whole labels, rather
  # than treating "Action;Adventure" as a separate genre or duplicating rows.
  genre_match <- rep(TRUE, nrow(data))
  if (!is.null(genres)) {
    genre_match <- vapply(
      strsplit(data$genres, ";", fixed = TRUE),
      function(labels) any(trimws(labels) %in% genres),
      logical(1)
    )
  }

  data |>
    filter(
      is.finite(.data$price),
      .data$price <= .env$max_price,
      is.finite(.data$total_reviews),
      .data$total_reviews >= .env$min_reviews,
      .env$genre_match
    )
}

#' Summarise selected Steam games
#'
#' Give each game equal weight when calculating the median positive
#' percentage. This is not a percentage pooled over every game's reviews.
#'
#' @param data A data frame containing price, positive_percent and total_reviews.
#' @return A one-row data frame with n_games, median_price,
#'   median_positive_percent and total_reviews. Empty selections have zero
#'   games and reviews, and NA medians.
#' @importFrom dplyr n summarise
#' @export
#' @examples
#' games <- filter_games(steam_games, "Action", 20, 100)
#' summarise_games(games)
summarise_games <- function(data) {
  required <- c("price", "positive_percent", "total_reviews")
  if (!is.data.frame(data) || !all(required %in% names(data))) {
    stop("data must contain price, positive_percent and total_reviews.",
         call. = FALSE)
  }

  data |>
    summarise(
      n_games = n(),
      median_price = stats::median(.data$price, na.rm = TRUE),
      median_positive_percent =
        stats::median(.data$positive_percent, na.rm = TRUE),
      total_reviews = sum(.data$total_reviews, na.rm = TRUE)
    )
}
