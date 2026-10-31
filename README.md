# steamfinder

steamfinder helps Steam players compare games within a historical budget
and genre selection. It asks: which games meet these conditions, and how
do their positive review percentages compare?

## Data

The source is Steam_games, deposited by Tuvshin Selenge on Zenodo:

- Source: https://doi.org/10.5281/zenodo.7904761
- Original file: steam.csv, with 27,075 games and 18 variables.
- Prepared package data: steam_games, with 27,075 games and nine variables.
- Preparation script: data-raw/prepare-steam-data.R.
- Data licence: CC BY 4.0. Package code is licensed separately under MIT.

Each prepared row is one game. Genres can contain several labels separated
by semicolons. Total reviews are positive plus negative reviews; positive
percentage is the positive count divided by the total, multiplied by 100.

This is a historical snapshot containing release dates through May 2019.
The 2023 Zenodo deposit date does not make the observations current.
Prices are historical GBP list prices before discounts, following the
[original cleaning methodology](https://nik-davis.github.io/posts/2019/steam-data-cleaning/).
Neither prices nor review counts should be treated as live Steam listings.

## Installation

Install the GitHub version:

```r
install.packages("remotes")
remotes::install_github("ETC5523-2026/etc5523-assignment-4-shee0080")
```

## Launch the app

```r
library(steamfinder)
run_app()
```

Follow the three numbered controls: genres, maximum historical price
in GBP and minimum review count. Type the budget directly; use 0 to
select free games only. Start with Action, GBP 20 and at least 100 reviews.

Three cards show matching games, median historical price and the median
positive review share. The selection message states the filters in use.
Multiple genres match using "any", with each game counted once.

Switch between Price & reviews for the scatterplot and Matching games
for the table. Both tabs use the same selection. The table shows up to
20 games; the cards describe all matches.

Clearing the genres or entering an invalid number shows dashes on the
cards and a specific instruction in the selection message. Valid filters
with no matches show zero games and undefined medians labelled "No matches".

With Action and at least 100 reviews, reducing the budget from GBP 20
to zero reduces the selection from 3,705 to 491 games. These selections
overlap: the GBP 20 group includes free games. The comparison does not
show that paying more causes better reviews.

## Use the functions

```r
games <- filter_games(
  steam_games,
  genres = "Action",
  max_price = 20,
  min_reviews = 100)
summarise_games(games)
```

These settings select 3,705 games, with a median historical price of
GBP 5.99 and a median positive review percentage of about 79.1%.
The median gives every game equal weight; it does not pool all reviews.
This calculated percentage is not Steam's official review classification.

## Reproduce the data

From the repository root:

```r
source("data-raw/prepare-steam-data.R")
```

The script reads the saved source CSV, selects seven original fields,
converts release dates and adds total_reviews and positive_percent.
It saves the prepared object to data/steam_games.rda.
The running app uses the installed object and does not read this CSV.

## Documentation

Configured documentation address:
[steamfinder documentation](https://etc5523-2026.github.io/etc5523-assignment-4-shee0080/).

## Limitations

Reviewers are self-selected, and percentages from few reviews can be
unstable. A minimum review threshold does not eliminate these biases.
Historical price differences cannot establish that paying more causes
a higher rating. These results support exploration of the snapshot, rather
than current buying recommendations.

## AI Announcement
