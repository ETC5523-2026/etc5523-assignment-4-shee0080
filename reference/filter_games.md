# Filter historical Steam games

Keep games within a budget and review-count threshold. A game can have
several semicolon-separated genres; matching any selected genre is
enough, and each game is returned only once.

## Usage

``` r
filter_games(data, genres = NULL, max_price = Inf, min_reviews = 0)
```

## Arguments

- data:

  A data frame with the columns in
  [steam_games](https://etc5523-2026.github.io/etc5523-assignment-4-shee0080/reference/steam_games.md).

- genres:

  Character vector of genre labels. NULL includes every genre;
  character(0) returns no games.

- max_price:

  One non-negative historical price in GBP. Inf includes all prices.

- min_reviews:

  One finite, non-negative minimum review count.

## Value

A data frame with the matching rows and original columns.

## Examples

``` r
games <- filter_games(steam_games, "Action", 20, 100)
utils::head(games, 3)
#>   appid                  name release_date genres price positive_ratings
#> 1    10        Counter-Strike   2000-11-01 Action  7.19           124534
#> 2    20 Team Fortress Classic   1999-04-01 Action  3.99             3318
#> 3    30         Day of Defeat   2003-05-01 Action  3.99             3416
#>   negative_ratings total_reviews positive_percent
#> 1             3339        127873         97.38882
#> 2              633          3951         83.97874
#> 3              398          3814         89.56476
```
