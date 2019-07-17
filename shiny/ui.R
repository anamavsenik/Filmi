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
                            sidebarMenu(id="drzave",
                                        menuItem("Domov", tabName = "domov", selected = TRUE)),
                            sidebarMenu(id="vojne",
                                        menuItem("Iskanje po naslovu filma",tabName = "filmi")),
                            sidebarMenu(id="stat", 
                                        menuItem("Iskanje po igralcih", tabName = "igralci")),
                            sidebarMenu(id="nagrada",
                                        menuItem("Isaknje po nagradah",tabName = "nagrada")),
                            sidebarMenu(id="zanr",
                                        menuItem("Isanke po zanru",tabName = "zanr")),
                            sidebarMenu(id="leto",
                                        menuItem("Isaknje po letu izida",tabName = "leto")),
                            sidebarMenu(id="ocena",
                                        menuItem("Ocenjevanje filmov",tabName = "ocena"))
)


body <- dashboardBody(
  tabItems(
    tabItem(tabName = "domov",
            fluidRow(sidebarPanel(
              h3("Dobrodosel! Na tej spletni strani lahko brskas med filmi, poisces svoje najljubse igralce ali pa film, ki si ga ze pogledal ocenis! Ali ni to kul? ",align = "center")
            ),
            mainPanel(img(src = "Popcorn.jpg", height = 200, width = 1000)
            ))),
    tabItem(tabName = "filmi",
            fluidRow(sidebarPanel((
              textInput(inputId="film",label="Naslov filma","....")
              )),
              mainPanel(DT::dataTableOutput("voj"),
                        img(src="filmi.png", height = 200, width = 400)
              ))),
    tabItem(tabName = "igralci",
            fluidRow(sidebarPanel(
                textInput(inputId="igralec", label="Igralec", "Angelina Jolie")
            )),
            mainPanel(DT::dataTableOutput("stat"),
                      img(src="igralke.jpg")
            )),
    tabItem(tabName = "ocena",
            fluidRow(
              sidebarPanel(textInput("komentar", "Dodaj svoje mnenje", value = ""),
                           actionButton(inputId = "komentar_gumb",label = "Dodaj komentar"),
                           verbatimTextOutput("value"),
                           uiOutput("izbrana.vojna")),
              mainPanel(p("Oceni filme, najboljsi si zasluzi tvojih pet tock"),
                        DT::dataTableOutput("komentiranje"))
              
            )))
)

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



