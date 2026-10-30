test_that("genres match complete labels without duplicating games", {
  games <- data.frame(
    appid = 1:3,
    genres = c("Action;Adventure", "Adventure", "ActionRPG"),
    price = c(0, 5, 10),
    total_reviews = c(100, 200, 300),
    positive_percent = c(80, 90, 70)
  )

  expect_equal(filter_games(games, "Action")$appid, 1L)
  both <- filter_games(games, c("Action", "Adventure"))
  expect_equal(both$appid, 1:2)
  expect_equal(anyDuplicated(both$appid), 0L)
  expect_equal(nrow(filter_games(games, character(0))), 0L)
  expect_equal(nrow(filter_games(games, NULL)), 3L)
})

test_that("budgets include their boundary and free games", {
  games <- data.frame(
    genres = rep("Action", 3),
    price = c(0, 5, 10),
    total_reviews = c(100, 200, 300),
    positive_percent = c(80, 90, 70)
  )

  expect_equal(nrow(filter_games(games, "Action", 0, 100)), 1L)
  expect_equal(nrow(filter_games(games, "Action", 5, 100)), 2L)
  expect_equal(nrow(filter_games(games, "Action", 5, 201)), 0L)
  expect_error(filter_games(games, max_price = -1), "non-negative")
})

test_that("an empty selection has undefined medians", {
  empty <- steam_games[0, ]
  result <- summarise_games(empty)

  expect_equal(result$n_games, 0L)
  expect_equal(result$total_reviews, 0)
  expect_true(is.na(result$median_price))
  expect_true(is.na(result$median_positive_percent))
})

test_that("the median percentage weights games rather than reviews", {
  games <- data.frame(
    price = c(0, 10, 20),
    total_reviews = c(10, 100, 10000),
    positive_percent = c(10, 50, 90)
  )
  result <- summarise_games(games)

  expect_equal(result$n_games, 3L)
  expect_equal(result$median_price, 10)
  expect_equal(result$median_positive_percent, 50)
  expect_equal(result$total_reviews, 10110)
})
