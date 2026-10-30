library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)

games <- steamfinder::steam_games
genre_choices <- sort(unique(trimws(unlist(
  strsplit(games$genres, ";", fixed = TRUE)
))))

ui <- page_sidebar(
  title = "Steam Game Finder",
  fillable = FALSE,
  theme = bs_theme(
    version = 5, primary = "#176B87"
  ),
  tags$head(tags$link(
    rel = "stylesheet", type = "text/css", href = "styles.css"
  )),
  sidebar = sidebar(
    title = "Choose your games",
    selectInput(
      "genres", "Genres", choices = genre_choices,
      selected = "Action", multiple = TRUE
    ),
    sliderInput(
      "max_price", "Maximum historical price (GBP)",
      min = 0, max = ceiling(max(games$price) / 5) * 5,
      value = 20, step = 1
    ),
    numericInput(
      "min_reviews", "Minimum number of reviews",
      value = 100, min = 0, step = 100
    ),
    helpText(
      "Games must match the budget and review threshold.",
      "If you select several genres, matching any one is enough.",
      "A game is counted only once."
    )
  ),
  h2("Compare games within your budget"),
  p(
    "For Steam players: within your chosen budget and genres,",
    "which games appear in this historical dataset,",
    "and how do their player reviews compare?"
  ),
  p(
    class = "limit-note",
    "Historical snapshot, not live prices or reviews.",
    "Prices use GBP and include free games.",
    "Source:",
    tags$a(
      "Steam_games on Zenodo",
      href = "https://doi.org/10.5281/zenodo.7904761",
      target = "_blank", rel = "noopener"
    )
  ),
  layout_columns(
    value_box("Matching games", textOutput("number_shown")),
    value_box("Median price (GBP)", textOutput("median_price")),
    value_box("Median positive reviews (%)", textOutput("median_positive"))
  ),
  div(class = "selection-message", textOutput("selection_status")),
  card(
    card_header("Price and positive review percentage"),
    p(
      "Each dot is one matching game.",
      "Higher dots have a larger share of positive reviews;",
      "dots further right have a higher historical price."
    ),
    plotOutput("price_plot", height = "380px")
  ),
  card(
    card_header("Matching games"),
    p(
      "Up to 20 games, ordered by positive review percentage,",
      "then review count. This is a browsing aid, not a current buying recommendation."
    ),
    div(class = "table-scroll", tableOutput("games_table"))
  ),
  card(
    card_header("How to interpret these results"),
    p(
      "Positive review percentage is positive reviews divided by",
      "positive plus negative reviews, multiplied by 100.",
      "The median percentage gives each matching game equal weight."
    ),
    p(
      "Games with few reviews can have unstable percentages.",
      "Use the minimum-review control to examine this.",
      "Genres overlap, reviews reflect reviewers rather than all players,",
      "and these historical observations cannot establish that",
      "a higher price causes a higher rating."
    )
  )
)

server <- function(input, output, session) {
  selected_games <- reactive({
    validate(
      need(length(input$genres) > 0, "Select at least one genre."),
      need(
        !is.null(input$max_price) && is.finite(input$max_price) &&
          input$max_price >= 0,
        "Choose a non-negative maximum price."
      ),
      need(
        !is.null(input$min_reviews) && is.finite(input$min_reviews) &&
          input$min_reviews >= 0,
        "Enter a non-negative minimum review count."
      )
    )
    steamfinder::filter_games(
      games, genres = input$genres,
      max_price = input$max_price,
      min_reviews = input$min_reviews
    )
  })

  summary_data <- reactive({
    steamfinder::summarise_games(selected_games())
  })

  output$number_shown <- renderText({
    format(summary_data()$n_games, big.mark = ",", scientific = FALSE)
  })
  output$median_price <- renderText({
    x <- summary_data()$median_price
    if (is.na(x)) "No matches" else sprintf("%.2f", x)
  })
  output$median_positive <- renderText({
    x <- summary_data()$median_positive_percent
    if (is.na(x)) "No matches" else sprintf("%.1f", x)
  })
  output$selection_status <- renderText({
    n <- summary_data()$n_games
    if (n == 0) {
      "No games match these filters. Increase the budget, lower the review threshold, or choose another genre."
    } else {
      stats <- summary_data()
      paste0(
        format(n, big.mark = ","), " games match. Their median historical ",
        "price is GBP ", sprintf("%.2f", stats$median_price),
        " and their median positive review percentage is ",
        sprintf("%.1f", stats$median_positive_percent),
        "%. The table lists up to 20 of these games."
      )
    }
  })
  output$price_plot <- renderPlot({
    selected <- selected_games()
    validate(need(
      nrow(selected) > 0,
      "No games match. Increase the budget or lower the review threshold."
    ))
    ggplot(selected, aes(x = price, y = positive_percent)) +
      geom_point(colour = "#176B87", alpha = 0.45, size = 1.8) +
      scale_y_continuous(limits = c(0, 100)) +
      labs(
        x = "Historical list price (GBP)",
        y = "Positive review percentage (%)"
      ) +
      theme_minimal(base_size = 14)
  })
  output$games_table <- renderTable({
    selected <- selected_games()
    validate(need(
      nrow(selected) > 0,
      "No games match. Try a different genre or broader filters."
    ))
    selected |>
      arrange(desc(positive_percent), desc(total_reviews), price, appid) |>
      slice_head(n = 20) |>
      mutate(
        price = sprintf("%.2f", price),
        total_reviews = format(
          total_reviews, big.mark = ",", scientific = FALSE, trim = TRUE
        ),
        positive_percent = sprintf("%.1f", positive_percent)
      ) |>
      select(
        Game = name,
        Genres = genres,
        "Price (GBP)" = price,
        Reviews = total_reviews,
        "Positive (%)" = positive_percent
      )
  }, rownames = FALSE, striped = TRUE, digits = 2)
}

shinyApp(ui, server)

