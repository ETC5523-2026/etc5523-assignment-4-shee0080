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
  theme = bs_theme(version = 5, primary = "#176B87"),
  tags$head(tags$link(
    rel = "stylesheet", type = "text/css", href = "styles.css"
  )),
  sidebar = sidebar(
    title = "Set your filters",
    width = 290,
    open = list(desktop = "open", mobile = "closed"),
    class = "filter-sidebar",
    p("Choose a group of games, then compare their prices and reviews."),
    selectInput(
      "genres", "1. Genres", choices = genre_choices,
      selected = "Action", multiple = TRUE
    ),
    helpText(
      "Select one or more. Matching any selected genre is enough;",
      "each game is counted once."
    ),
    numericInput(
      "max_price", "2. Maximum price (GBP)",
      value = 20, min = 0, step = 1, width = "100%"
    ),
    helpText("Enter 0 to see free games only. Prices are historical GBP."),
    numericInput(
      "min_reviews", "3. Minimum reviews",
      value = 100, min = 0, step = 100, width = "100%"
    ),
    helpText("The total number of positive plus negative reviews."),
    div(
      class = "starting-point",
      strong("Start here"),
      p("Try Action, a GBP 20 budget and at least 100 reviews."),
      p("Then change the budget to 0 and compare the selection.")
    )
  ),
  div(
    class = "steam-heading",
    h2("Which games fit your budget?"),
    p(
      "For Steam players exploring historical game prices and reviews.",
      "Choose your filters to find matching titles and compare their",
      "positive review percentages."
    ),
    p(class = "scope-note", "Historical snapshot through May 2019. Prices and reviews are not live.")
  ),
  layout_columns(
    class = "steam-stats",
    value_box(
      title = "Matching games",
      value = textOutput("number_shown"),
      p("All games meeting your filters."),
      theme = "light", class = "metric-card"
    ),
    value_box(
      title = "Median price (GBP)",
      value = textOutput("median_price"),
      p("The middle historical price among matches."),
      theme = "light", class = "metric-card"
    ),
    value_box(
      title = "Median positive share (%)",
      value = textOutput("median_positive"),
      p("Each game has equal weight in this median."),
      theme = "light", class = "metric-card"
    )
  ),
  div(
    class = "selection-message", role = "status",
    "aria-live" = "polite",
    strong("Your current selection"),
    textOutput("selection_status")
  ),
  navset_card_tab(
    id = "results_view", selected = "plot",
    nav_panel(
      "Price & reviews", value = "plot",
      h3("Compare price and positive reviews"),
      p(
        "Each dot is one matching game. Higher dots have a larger",
        "positive review percentage; dots further right have a higher",
        "historical price."
      ),
      plotOutput("price_plot", height = "390px"),
      p(
        class = "scope-note",
        "The chart includes every matching game.",
        "A pattern between price and reviews does not establish causation."
      )
    ),
    nav_panel(
      "Matching games", value = "games",
      h3("Inspect the game titles"),
      p(
        "Up to 20 games, ordered by positive review percentage and",
        "then review count. The cards describe all matches, not just these rows."
      ),
      div(class = "table-scroll", tableOutput("games_table")),
      p(
        class = "scope-note",
        "This ordering helps you browse the historical data;",
        "it is not a current buying recommendation."
      )
    ),
    wrapper = function(...) {
      card_body(..., fillable = FALSE, fill = FALSE)
    }
  ),
  card(
    class = "reading-card",
    card_header("Read the results with their limits"),
    p(
      strong("Positive share:"),
      "positive reviews divided by total reviews, multiplied by 100.",
      "It is not Steam's official review classification."
    ),
    p(
      strong("Median:"),
      "the middle value across the matching games.",
      "The median positive share gives each game equal weight;",
      "it does not pool every game's reviews together."
    ),
    p(
      strong("Review coverage:"),
      "percentages based on few reviews can be unstable.",
      "A higher minimum review count changes the selection,",
      "but it does not remove reviewer-selection bias."
    )
  ),
  p(
    class = "source-note",
    "Data:",
    tags$a(
      "Steam_games on Zenodo (CC BY 4.0)",
      href = "https://doi.org/10.5281/zenodo.7904761",
      target = "_blank", rel = "noopener"
    ),
    ". Historical GBP prices and review counts."
  )
)

server <- function(input, output, session) {
  # One input check supplies the cards, message and shared selection.
  input_problem <- reactive({
    if (length(input$genres) == 0) {
      return("Choose at least one genre in the sidebar to compare games.")
    }
    if (is.null(input$max_price) ||
        !is.finite(input$max_price) || input$max_price < 0) {
      return("Enter a non-negative maximum price in GBP. Use 0 for free games.")
    }
    if (is.null(input$min_reviews) ||
        !is.finite(input$min_reviews) || input$min_reviews < 0) {
      return("Enter a non-negative minimum review count.")
    }
    NULL
  })

  selected_games <- reactive({
    problem <- input_problem()
    validate(need(
      is.null(problem),
      if (is.null(problem)) "" else problem
    ))
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
    if (!is.null(input_problem())) return("\u2014")
    format(summary_data()$n_games, big.mark = ",", scientific = FALSE)
  })
  output$median_price <- renderText({
    if (!is.null(input_problem())) return("\u2014")
    x <- summary_data()$median_price
    if (is.na(x)) "No matches" else sprintf("%.2f", x)
  })
  output$median_positive <- renderText({
    if (!is.null(input_problem())) return("\u2014")
    x <- summary_data()$median_positive_percent
    if (is.na(x)) "No matches" else sprintf("%.1f", x)
  })
  output$selection_status <- renderText({
    if (!is.null(input_problem())) return(input_problem())
    n <- summary_data()$n_games
    if (n == 0) {
      return(
        "No games match. Increase the budget, lower the review threshold, or choose another genre."
      )
    }
    paste0(
      format(n, big.mark = ","), " games match ",
      paste(input$genres, collapse = " or "),
      ", a budget of GBP ", sprintf("%.2f", input$max_price),
      " and at least ",
      format(input$min_reviews, big.mark = ",", scientific = FALSE, trim = TRUE),
      " reviews. Both tabs use this selection; the table shows up to 20 games."
    )
  })
  output$price_plot <- renderPlot({
    # The message above explains incomplete inputs; clear the plot until valid.
    req(is.null(input_problem()))
    selected <- selected_games()
    validate(need(
      nrow(selected) > 0,
      "No games match. Broaden the filters in the sidebar."
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
    req(is.null(input_problem()))
    selected <- selected_games()
    validate(need(
      nrow(selected) > 0,
      "No games match. Broaden the filters in the sidebar."
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
