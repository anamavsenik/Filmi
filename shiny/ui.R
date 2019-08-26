source("../lib/libraries.R")


vpisniPanel <- tabPanel("SignIn", value="signIn",
                        fluidPage(
                          fluidRow(
                            column(width = 12,
                                   align = "middle",
                                   textInput("userName","User name", value= ""),
                                   passwordInput("password","Password", value = ""),
                                   actionButton("signin_btn", "Sign In"),
                                   actionButton("signup_btn", "Sign Up"))
                          )))

registracijaPanel <- tabPanel("SignUp", value = "signUp",
                              fluidPage(
                                fluidRow(
                                  column(width = 12,
                                         align="center",
                                         textInput("SignUpUserName","* Username", value= "", placeholder = "Only Latin characters."),
                                         passwordInput("SignUpPassword","* Password", value= "", placeholder = "Only Latin characters."),
                                         actionButton("signup_btnBack", "Back"),
                                         actionButton("signup_btnSignUp", "Sign Up")
                                  )
                                )
                              )
)


sidebar <- dashboardSidebar(hr(),
                            sidebarMenu(id="domov",
                                        menuItem("Domov", tabName = "domov", selected = TRUE)),
                            sidebarMenu(id="filmi",
                                        menuItem("Iskanje po naslovu filma",tabName = "filmi")),
                            sidebarMenu(id="igralci", 
                                        menuItem("Iskanje po igralcih", tabName = "igralci")),
                            sidebarMenu(id="nagrada",
                                        menuItem("Iskanje po nagradah",tabName = "nagrada")),
                            sidebarMenu(id="zanr",
                                        menuItem("Iskanje po zanru",tabName = "zanr")),
                            sidebarMenu(id="leto",
                                        menuItem("Iskanje po letu izida",tabName = "leto")),
                            sidebarMenu(id="ocena",
                                        menuItem("Ocenjevanje filmov",tabName = "ocena"))
)


body <- dashboardBody(
  tabItems(
    tabItem(tabName = "domov",
            fluidRow(sidebarPanel(
              h3("Dobrodošel! Na tej spletni strani lahko brskaš med filmi, najdeš svoje najljubše igralce ali pa film, ki si ga že pogledal, oceniš! Ali ni to kul? ",align = "center")
            ),
            mainPanel(img(src = "Popcorn.jpg", height = 200, width = 1000)
                      ))),
    tabItem(tabName = "filmi",
            fluidRow(sidebarPanel(
              uiOutput("ui_film"),
              width = 8
              )),
              mainPanel(p("Bi rad izvedel več o svojem najljubšem filmu?"),
                DT::dataTableOutput("izbran.naslov5"),
                          dataTableOutput("izbran.naslov"),
                        textOutput("izbran.naslov3"),
                        dataTableOutput("izbran.naslov2"),
                        textOutput("izbran.naslov4"),
                        img(src="filmi.png", height = 200, width = 400),
                        width=18
              )),
    tabItem(tabName = "igralci",
            fluidRow(
              sidebarPanel(
                uiOutput("ui_igralec"),
                width = 5
            )),
            mainPanel(p("Bi rad pregledal vse filme svojega najljubšega igralca, pa jih ne poznaš?"),
                      DT::dataTableOutput("izberi.igralca"),
                      img(src="igralke.jpg"),
                      width=18
            )),
    tabItem(tabName = "ocena",
            fluidRow(
              sidebarPanel(textInput("komentar", "Dodaj svoje mnenje", value = ""),
                           numericInput("stevilka","Oceni film",value=1, min=1,max=5),
                           actionButton(inputId = "komentar_gumb",label = "Komentiraj in oceni"),
                           verbatimTextOutput("value"),
                           width = 5,
                           uiOutput("izbran.film")),
              mainPanel(p("Oceni filme! Najboljši si zasluži tvojih pet točk!"),
                        DT::dataTableOutput("komentiranje"))
            )),
    tabItem(tabName = "leto",
            fluidRow(
              sidebarPanel(
                sliderInput("leta", 
                            "Leto izida filma:",
                            min = 1800, max = 2020,
                            value = c(1800,2020))),
              mainPanel(p("Hmm, le kateri filmi so stari že več kot 30 let...? "),
                DT::dataTableOutput("tabela_leto"),
                img(src="leto.jpg", height = 200, width = 400)
              ))),
    tabItem(tabName = "zanr",
            fluidRow(
              sidebarPanel(
                uiOutput("ui_zanr")
              ),
              mainPanel(p("Bi rad spisek dobrih komedij/dram/grozljivk..??"),
                DT::dataTableOutput("izberi.zanr"),
                img(src="komedija.jpg", height = 200, width = 400)
              ))
    ),
    tabItem(tabName = "nagrada",
            fluidRow(
              sidebarPanel(
                selectInput("Nagrada", "Izberi moznost:", 
                            choices = c("Nagrada igralca","Nagrada filma")),
                numericInput("leto_nagrade", "Leto izzida:", '1980', min = 1800, max = 2020)
              ),
              mainPanel(p("Oglej si, kdo je dobil oskarja v izbranem letu!"),
                        DT::dataTableOutput("izbrana.nagrada"),
                        img(src="oscars.jpg", height = 200, width = 400)
              )))
  ))
  


fluidPage(useShinyjs(),
          conditionalPanel(condition = "output.signUpBOOL!='1' && output.signUpBOOL!='2'",#&& false", 
                           vpisniPanel),       # UI panel za vpis
          conditionalPanel(condition = "output.signUpBOOL=='1'", registracijaPanel),  # UI panel registracija
          conditionalPanel(condition = "output.signUpBOOL=='2'",    # Panel, ko si ze vpisan
                           dashboardPage(#dashboardHeader(disable=T),
                             dashboardHeader(title = "FILMI",
                                             tags$li(class = "dropdown",
                                                     tags$li(class = "dropdown", textOutput("dashboardLoggedUser"), style = "padding-top: 15px; padding-bottom: 15px; color: #fff;"),
                                                     tags$li(class = "dropdown", actionLink("dashboardLogin", textOutput("logintext")))
                                             )),
                             sidebar,
                             body,
                             skin = "yellow")),
          theme="bootstrap.css"
)



