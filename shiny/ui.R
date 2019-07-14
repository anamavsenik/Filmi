vpisniPanel <- tabPanel("SignIn", value="signIn",
                        fluidPage(
                          HTML('<body background = "https://pixel.nymag.com/imgs/fashion/daily/2018/11/02/2-empty-movie-theatre.w1200.h630.jpg"></body>'),
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
                                      menuItem("Pregled vojn po skupinah", tabName = "drzave", selected = TRUE)),
                          sidebarMenu(id="vojne",
                                        menuItem("Pregled vojn",tabName = "vojne")),
                            sidebarMenu(id="stat", 
                                        menuItem("Statistika po sodelujocih", tabName = "stat")),
                            sidebarMenu(id="komentar_tab", 
                                        menuItem("Civilen diskurz o vojnah", tabName = "koment"))
                            
)

body <- dashboardBody(
  tabItems(
    tabItem(tabName = "drzave",
            fluidRow(sidebarPanel(
              uiOutput("izbor.sodelujoci")
            ),
            mainPanel(DT::dataTableOutput("sodel")
            ))),
    tabItem(tabName = "vojne",
            fluidRow(
              column(5,
                     numericInput("min_max1", "Stevilo zrtev od", min=0, max=17000000, value=0)
              ),
              column(5,
                     numericInput("min_max2", "Stevilo zrtev do", min=0, max=17000000, value=17000000)
              )
              ,
              mainPanel(DT::dataTableOutput("voj")
              ))),
    tabItem(tabName = "stat",
            #fluidRow(sidebarPanel(
            # uiOutput("izbor.statistika")
            #),
            mainPanel(DT::dataTableOutput("stat"),
                      plotOutput("drsnik")
            )),
    tabItem(tabName = "koment",
            fluidRow(
              sidebarPanel(textInput("komentar", "Dodaj svoje mnenje", value = ""),
                           actionButton(inputId = "komentar_gumb",label = "Dodaj komentar"),
                           verbatimTextOutput("value"),
                           uiOutput("izbrana.vojna")),
              mainPanel(p("Prosimo, da na strani drzite komentarje na primerni ravni"),
                        DT::dataTableOutput("komentiranje"))
              
            )))
)

fluidPage(useShinyjs(),
          conditionalPanel(condition = "output.signUpBOOL!='1' && output.signUpBOOL!='2'",#&& false", 
                           vpisniPanel),       # UI panel za vpis
          conditionalPanel(condition = "output.signUpBOOL=='1'", registracijaPanel),  # UI panel registracija
          conditionalPanel(condition = "output.signUpBOOL=='2'",    # Panel, ko si ze vpisan
                           dashboardPage(#dashboardHeader(disable=T),
                             dashboardHeader(title = "Pregled vojn",
                                             tags$li(class = "dropdown",
                                                     tags$li(class = "dropdown", textOutput("dashboardLoggedUser"), style = "padding-top: 15px; padding-bottom: 15px; color: #fff;"),
                                                     tags$li(class = "dropdown", actionLink("dashboardLogin", textOutput("logintext")))
                                             )),
                             sidebar,
                             body,
                             skin = "blue")),
          theme="bootstrap.css"
)

