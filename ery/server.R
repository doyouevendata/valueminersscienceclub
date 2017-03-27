# Check if packages are installed and loaded.
for (package in c("shiny","plotly","moments")) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}

server <- function(input, output) {
  
  # Read and transform data
  alltogether <- data.frame(read.csv(file = "dji.csv", sep = ",", header = TRUE))
  
  # Shift (range) to be used for histogram
  shift <- 649
  observations <- nrow(alltogether)
  
  #change column names to simplify
  colnames(alltogether) <- c("daty","stopy","ceny")
  
  # Generate statistic magic values
  for (i in observations:as.numeric(shift+1)){
    n = i-shift
    alltogether$means[i] <- mean(alltogether$ceny[n:i])
    alltogether$variance[i] <- var(alltogether$ceny[n:i])
    alltogether$skewness[i] <- skewness(alltogether$ceny[n:i])
    alltogether$kurtosis[i] <- kurtosis(alltogether$ceny[n:i])
  }
  
  # render 
  output$plot <- renderPlotly({ 
    
    f <- event_data("plotly_click", source = "source")
    datapoint <- f$pointNumber[1]
    shifteddatapoint <- datapoint-shift
    cenymin <- min(alltogether$ceny)
    cenymax <- max(alltogether$ceny)
    
    
    ay <- list(
      tickfont = list(color = "red"),
      overlaying = "y",
      side = "right",
      title = "Stopa zwrotu",
      range = c(-0.14,0.3)
    )
    p <- plot_ly(source = "source") %>%
      add_lines(data = alltogether, x = ~daty, y = ~ceny, name = "cena", text = ~paste("srednia: ", alltogether$means)) %>%
      add_lines(data = alltogether, x = ~daty, y = ~stopy, name = "stopa zwrotu", yaxis = "y2") %>%
      layout(title = "Cena i stopa zwrotu", yaxis2 = ay)
    
    if (datapoint > shift && !is.null(datapoint)){
      line <- list(
        type = "line",
        line = list(color = "pink"),
        xref = "x",
        yref = "y"
      )
      lines <- list()
      for (i in c(shifteddatapoint,datapoint)){
        line[["x0"]] <- i
        line[["x1"]] <- i
        line[["y0"]] <- cenymin
        line[["y1"]] <- cenymax
        lines <- c(lines, list(line))
      }
      p <- layout(p, shapes = lines)
    }
    p
  })
  
  output$histogram <- renderPlotly({
    
    # Variables needed to show range
    cenymin <- min(alltogether$ceny)
    cenymax <- max(alltogether$ceny)
    
    # Read in hover data
    eventdata <- event_data("plotly_click", source = "source")
    validate(need(!is.null(eventdata), "Kliknij na wykres powyżej aby wygenerować histogram"))
    
    # Get point number
    datapoint <- as.numeric(eventdata$pointNumber)[1]
    
    # Get window length
    window <- as.numeric(input$window)
    
    # Show histogram
    shifteddatapoint <- datapoint + shift
    rangy <- (alltogether$stopy[datapoint:shifteddatapoint])
    
    if (datapoint > shift){
      plot_ly(x=rangy, type="histogram")
    }
    
  })
}
