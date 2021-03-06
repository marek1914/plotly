#' Shiny bindings for plotly
#' 
#' Output and render functions for using plotly within Shiny 
#' applications and interactive Rmd documents.
#' 
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{"100\%"},
#'   `"400px"`, `"auto"`) or a number, which will be coerced to a
#'   string and have `"px"` appended.
#' @param inline use an inline (`span()`) or block container 
#' (`div()`) for the output
#' @param expr An expression that generates a plotly
#' @param env The environment in which to evaluate `expr`.
#' @param quoted Is `expr` a quoted expression (with `quote()`)? This 
#'   is useful if you want to save an expression in a variable.
#'   
#' @importFrom htmlwidgets shinyWidgetOutput
#' @importFrom htmlwidgets shinyRenderWidget
#' @name plotly-shiny
#'
#' @export
plotlyOutput <- function(outputId, width = "100%", height = "400px", 
                         inline = FALSE) {
  htmlwidgets::shinyWidgetOutput(
    outputId = outputId, 
    name = "plotly", 
    width = width, 
    height = height, 
    inline = inline, 
    package = "plotly"
  )
}

#' @rdname plotly-shiny
#' @export
renderPlotly <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  # this makes it possible to pass a ggplot2 object to renderPlotly()
  # https://github.com/ramnathv/htmlwidgets/issues/166#issuecomment-153000306
  expr <- as.call(list(call("::", quote("plotly"), quote("ggplotly")), expr))
  shinyRenderWidget(expr, plotlyOutput, env, quoted = TRUE)
}


#' Access plotly user input event data in shiny
#' 
#' This function must be called within a reactive shiny context.
#' 
#' @param event The type of plotly event. Currently 'plotly_hover',
#' 'plotly_click', 'plotly_selected', and 'plotly_relayout' are supported.
#' @param source a character string of length 1. Match the value of this string 
#' with the source argument in [plot_ly()] to retrieve the 
#' event data corresponding to a specific plot (shiny apps can have multiple plots).
#' @param session a shiny session object (the default should almost always be used).
#' @export
#' @author Carson Sievert
#' @examples \dontrun{
#' plotly_example("shiny", "event_data")
#' }

event_data <- function(event = c("plotly_hover", "plotly_click", "plotly_selected", 
                                 "plotly_relayout"), source = "A",
                       session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    stop("No reactive domain detected. This function can only be called \n",
         "from within a reactive shiny context.")
  }
  src <- sprintf(".clientValue-%s-%s", event[1], source)
  val <- session$rootScope()$input[[src]]
  if (is.null(val)) val else jsonlite::fromJSON(val)
}
