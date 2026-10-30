# Historical Steam game prices and player reviews

A prepared data set of 27,075 games. Each row represents one game,
identified by appid. Games can have several genre labels.

## Usage

``` r
steam_games
```

## Format

A data frame with 27,075 rows and 9 variables:

- appid:

  Unique Steam application identifier.

- name:

  Game title.

- release_date:

  Game release date, stored as a Date.

- genres:

  Genre labels separated by semicolons.

- price:

  Historical list price in GBP; zero denotes a free game.

- positive_ratings:

  Number of positive reviews in the snapshot.

- negative_ratings:

  Number of negative reviews in the snapshot.

- total_reviews:

  Positive plus negative review counts.

- positive_percent:

  Positive reviews divided by total reviews, multiplied by 100.

## Source

Tuvshin Selenge, Steam_games, Zenodo:
<https://doi.org/10.5281/zenodo.7904761>. Original price-cleaning
methodology:
<https://nik-davis.github.io/posts/2019/steam-data-cleaning/>.

## Details

Release dates range from 1997-06-30 to 2019-05-01. Review counts and
prices are historical, not current Steam listings. The positive
percentage is a simple derived proportion, not a reconstruction of
Steam's official review classification.

The source data are distributed under CC BY 4.0. Code in this package is
licensed separately under the MIT licence.

## Examples

``` r
utils::head(steam_games, 3)
#>   appid                  name release_date genres price positive_ratings
#> 1    10        Counter-Strike   2000-11-01 Action  7.19           124534
#> 2    20 Team Fortress Classic   1999-04-01 Action  3.99             3318
#> 3    30         Day of Defeat   2003-05-01 Action  3.99             3416
#>   negative_ratings total_reviews positive_percent
#> 1             3339        127873         97.38882
#> 2              633          3951         83.97874
#> 3              398          3814         89.56476
```
