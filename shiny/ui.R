#source() klele bomo napisal od kje naj črpa podatke

library(shiny)
library(shinythemes)

shinyUI(fluidPage(theme = "bootstrap.css",
                  
  
                  
                  headerPanel(
                    h1( class = "title", img(src='film007.jpg', height=50, width=1000))
                    
                  ),
                  
                  column(3,offset = 4, titlePanel("Iskalnik filmov")), 
                  
                  
                  mainPanel(
                    tabsetPanel(
                      
                      # ZAVIHEK: Iskanje po naslovu
                      tabPanel("Iskanje po naslovu",
                               
                               
                               sidebarPanel(
                                 textInput(inputId="film",label="Naslov filma","....")
                               ),
                               
                               mainPanel(
                                 tableOutput("film1451"),
                                 textOutput("film245")
                                 
                               )),
                      
                      tabPanel("Iskanje po izvajalcu",
                               sidebarPanel(
                                 textInput(inputId="izvajalec", label="Izvajalec", "Ace of Base")
                               ),
                               
                               mainPanel(
                                 tableOutput("izvajalec55"),
                                 textOutput("izvajalec2")
                                 
                               )
                      ),
                      
                      # ZAVIHEK: Iskanje po albumu    
                      tabPanel("Iskanje po albumu",
                               sidebarPanel(
                                 textInput(inputId="album",label="Album","Happy Nation")
                               ),
                               
                               mainPanel(
                                 tableOutput("album55"),
                                 textOutput("album2")
                               ) 
                               
                      ),
                      
                      # ZAVIHEK: Iskanje po zvrsti  
                      tabPanel("Iskanje po zvrsti",
                               sidebarPanel(
                                 textInput(inputId="album",label="Album","Happy Nation")
                               ),
                                 
                               mainPanel(
                                 tableOutput("seznam1")
                               )
                               
                      ),
                      
                      # ZAVIHEK: Iskanje po letu  
                      tabPanel("Iskanje po letu",
                               sidebarPanel(
                                 sliderInput("leta",
                                             "Leto skladbe:",
                                             min = 1970,
                                             max = 2015,
                                             value = c(1980,2000))
                               ),
                               
                               mainPanel(
                                 tableOutput("tabelaleta")
                               )
                      )
                      
                      
                    )    )    ) )    