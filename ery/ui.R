library(shiny)
library(plotly)
library(moments)

ui <- fluidPage(
  
  tags$head(
    tags$style(HTML("
                    @import url('http://fonts.googleapis.com/css?family=Biryani&subset=latin,latin-ext');
                    
                    h2 {
                    font-family: 'Biryani';
                    font-weight: 400;
                    line-height: 0.8;
                    }

                    h3 {
                    font-family: 'Biryani';
                    font-weight: 200;
                    line-height: 0.6;
                    }

                    .shiny-output-error { visibility: hidden; }
    "))
            

    ),
  
  h2("Ceny i stopy zwrotu"),
  plotlyOutput("plot"),
  h2("Histogram"),
  h3("Kliknij myszką na wykres by zobaczyć histogram"),
  plotlyOutput("histogram",width = "500px", height = "300px")
)