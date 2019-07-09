#nastavitev slik, da jih ne bomo potem klicali po urlju
bottom_left <- "http://intelliassist.co.in/wp-content/uploads/2015/11/movies-that-changed-my-life.png"
top_right <- "https://www.harwellvillagehall.co.uk/wp-content/uploads/2017/03/film-012.jpg"
top_left <-"http://www.os-atl.si/wp-content/uploads/2018/04/kamera.jpg"
bottom_right<-"https://media.unreel.me/prod/popcornflix/home-movie/3b4e61ec-6845-485e-8a4a-3ec1c036700d"

# pkgs
library(shiny)

# ui
ui <- tagList(
  
  #'////////////////////////////////////////
  # head + css
  tags$head(
    tags$link(href="file.css", rel="stylesheet", type="text/css")
  ),
  
  #'////////////////////////////////////////
  # UI
  shinyUI(
    
    # layout
    navbarPage(title = 'FILMI',
               
               
               # tab 1: landing page
               tabPanel(title = "Domov", 
                        
                        # parent container
                        tags$div(class="landing-wrapper",
                                 
                                 # child element 1: images
                                 tags$div(class="landing-block background-content",
                                          
                                          # top left
                                          img(src=top_left),
                                          
                                          # top right
                                          img(src=top_right),
                                          
                                          # bottom left
                                          img(src=bottom_left), 
                                          
                                          # bottom right
                                          
                                          img(src=bottom_right)
                                          
                                 ),
                                 
                                 # child element 2: content
                                 tags$div(class="landing-block foreground-content",
                                          tags$div(class="foreground-text",
                                                   tags$h1("Dobrodošli!"),
                                                   tags$p("Na tej spletni strani lahko brskaš med filmi, poiščeš svoje najljubše igralce, nagrade, ali pa oceniš film, če si ga seveda že sam pogledal."),
                                                   tags$p("Ali ni to kul?")
                                                   )
                                          )
                                 )
                        ),
               
               #'////////////////////////////////////////
               # tab 2: data
               tabPanel(title = "Išči po naslovu filma",
                        
                        sidebarPanel(
                          textInput(inputId="film",label="Naslov filma","....")
                        ),
                        
                        mainPanel(
                          tableOutput("film1451"),
                          textOutput("film245"),
                          img(src="https://motionarray.imgix.net/preview-25850YWa8tMOnzj-low_0015.jpg?w=660&q=60&fit=max&auto=format")
                        )
                        
                        )
               
               ,
               tabPanel("Igralci",
                        sidebarPanel(
                          textInput(inputId="igralec", label="Igralec", "Angelina Jolie")
                        ),
                        
                        mainPanel(
                          tableOutput("igralec55"),
                          textOutput("igralec2"),
                          img(src="http://cdn02.cdn.justjared.com/wp-content/uploads/headlines/2016/12/top-actresses-2016.jpg")
                          
                        )
               ),
               
               # ZAVIHEK: Iskanje po albumu    
               tabPanel("Iskanje po nagradah",
                        sidebarPanel(
                          textInput(inputId="leto nagrade",label="Nagrada","Oscar")
                        ),
                        
                        mainPanel(
                          tableOutput("narada55"),
                          textOutput("nagrada2"),
                          img(src="https://ocio.laopiniondemalaga.es/img_contenido/noticias/2019/02/729043/oscars.jpg")
                        ) 
                        
               ),
               
               # ZAVIHEK: Iskanje po zvrsti  
               tabPanel("Iskanje po žanru",
                        sidebarPanel(
                          textInput(inputId="Žanr",label="Žanr","Happy Nation")
                        ),
                        
                        mainPanel(
                          tableOutput("seznam1"),
                          img(src="http://separatescreens.com/wp-content/uploads/2016/11/download.png")
                        )
                        
               ),
               
               # ZAVIHEK: Iskanje po letu  
               tabPanel("Iskanje po letu",
                        sidebarPanel(
                          sliderInput("leta",
                                      "Leto izida filma:",
                                      min = 1900,
                                      max = 2019,
                                      value = c(1900,2019))
                        ),
                        
                        mainPanel(
                          tableOutput("tabelaleta"),
                          img(src="https://akm-img-a-in.tosshub.com/indiatoday/images/story/201705/647_050117043949.jpg")
                        )
               )
                        )
                        )
               )


# server
server <- shinyServer(function(input, output){
  
})

shinyApp(ui, server)



