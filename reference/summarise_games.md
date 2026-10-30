# Summarise selected Steam games

Give each game equal weight when calculating the median positive
percentage. This is not a percentage pooled over every game's reviews.

## Usage

``` r
summarise_games(data)
```

## Arguments

- data:

  A data frame containing price, positive_percent and total_reviews.

## Value

A one-row data frame with n_games, median_price, median_positive_percent
and total_reviews. Empty selections have zero games and reviews, and NA
medians.

## Examples

``` r
games <- filter_games(steam_games, "Action", 20, 100)
summarise_games(games)
#>   n_games median_price median_positive_percent total_reviews
#> 1    3705         5.99                79.10959      18046819
```
