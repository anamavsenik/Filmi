source("../lib/libraries.R")
source("../auth.R")
source("serverFunctions.R")

#tukaj klici sql, ki se povezejo na ui.R

shinyServer(function(input,output,session) {
  # Vzpostavimo povezavo
  drv <- dbDriver("PostgreSQL") 
  conn <- dbConnect(drv, dbname = db, host = host,
                    user = user, password = password)
  userID <- reactiveVal()    # Placeholder za userID
  loggedIn <- reactiveVal(FALSE)    # Placeholder za logout gumb oz vrednost gumba
  
  dbGetQuery(conn, "SET CLIENT_ENCODING TO 'utf8'; SET NAMES 'utf8'")
  
  cancel.onSessionEnded <- session$onSessionEnded(function() {
    dbDisconnect(conn) #ko zapremo shiny naj se povezava do baze zapre
  })
  output$signUpBOOL <- eventReactive(input$signup_btn, 1)
  outputOptions(output, 'signUpBOOL', suspendWhenHidden=FALSE)  # Da omogoca skrivanje/odkrivanje
  observeEvent(input$signup_btn, output$signUpBOOL <- eventReactive(input$signup_btn, 1))
  
  # Greyout of signin button
  observeEvent(c(input$userName,input$password), {
    shinyjs::toggleState("signin_btn", 
                         all(c(input$userName, input$password)!=""))
  })
  
  # Sign in protocol
  observeEvent(input$signin_btn,
               {signInReturn <- sign.in.user(input$userName, input$password)
               if(signInReturn[[1]]==1){
                 userID(signInReturn[[2]])
                 output$signUpBOOL <- eventReactive(input$signin_btn, 2)
                 loggedIn(TRUE)
               }else if(signInReturn[[1]]==0){
                 showModal(modalDialog(
                   title = "Error during sign in",
                   paste0("An error seems to have occured. Please try again."),
                   easyClose = TRUE,
                   footer = NULL
                 ))
               }else{
                 showModal(modalDialog(
                   title = "Wrong Username/Password",
                   paste0("Username or/and password incorrect"),
                   easyClose = TRUE,
                   footer = NULL
                 ))
               }
               })
  
  # Greyout of signup button
  observeEvent(c(input$SignUpUserName, input$SignUpPassword), {
    shinyjs::toggleState("signup_btnSignUp",
                         all(c(input$SignUpUserName, input$SignUpPassword)!="")# & 
                         # Preveri, ce samo latin characterji
                         # !any(grepl("[^\x20-\x7F]",
                         #         c(input$SignUpName, input$SignUpSurname, input$SignUpAddress, input$SignUpCity,
                         #           input$SignUpCountry, input$SignUpEmso, input$SignUpMail, 
                         #           input$SignUpUserName, input$SignUpPassword)))
    )
  })
  
  # Sign up protocol
  observeEvent(input$signup_btnSignUp,
               {
                 if(any(grepl("[^\x20-\x7F]",
                              c(input$SignUpUserName, input$SignUpPassword)))){
                   success <- -1
                 }else{
                   signUpReturn <- sign.up.user(input$SignUpUserName, input$SignUpPassword)
                   success <- signUpReturn[[1]]
                 }
                 if(success==1){
                   showModal(modalDialog(
                     title = "You have successfully signed up!",
                     paste0("Now you can login as ",input$SignUpUserName,''),
                     easyClose = TRUE,
                     footer = NULL
                   ))
                   output$signUpBOOL <- eventReactive(input$signup_btnSignUp, 0) 
                 }else if(success==-10){
                   showModal(modalDialog(
                     title = "Username conflict!",
                     paste0("The username ",input$SignUpUserName,' is already taken. Please,
                            chose a new one.'),
                     easyClose = TRUE,
                     footer = NULL
                     ))
                 }else if(success==-1){
                   showModal(modalDialog(
                     title = "Signup unsuccessful",
                     paste0("Only Latin characters allowed"),
                     easyClose = TRUE,
                     footer = NULL
                   ))
                 }else{
                   showModal(modalDialog(
                     title = "Error during sign up",
                     paste0("An error seems to have occured. Please try again."),
                     easyClose = TRUE,
                     footer = NULL
                   ))
                 }
               })
  
  # Back button to sign in page
  observeEvent(input$signup_btnBack, output$signUpBOOL <- eventReactive(input$signup_btnBack, 0))
  
  # Login/logout button in header
  observeEvent(input$dashboardLogin, {
    if(loggedIn()){
      output$signUpBOOL <- eventReactive(input$signin_btn, 0)
      userID <- reactiveVal()
    }
    loggedIn(ifelse(loggedIn(), FALSE, TRUE))
  })
  
  output$logintext <- renderText({
    if(loggedIn()) return("Logout here.")
    return("Login here")
  })
  
  output$dashboardLoggedUser <- renderText({
    if(loggedIn()) return(paste("Welcome,", pridobi.ime.uporabnika(userID())))
    return("")
  })

 

#------------------------------------------------------------------------------------------------
#zavihek iskanje po naslovu filma

output$ui_film<- renderUI({
  sqlOutput_film <- dbGetQuery(conn, build_sql("SELECT naslov FROM film", con = conn))
  selectInput("naslov",
              label = "Izberite film:",
              choices = sqlOutput_film)
})

  najdi.film<-reactive({
    validate(need(!is.null(input$naslov), "Izberite film:"))
    sql <- build_sql("SELECT DISTINCT film.id AS \"ID filma\", film.trajanje, posnet_po.id_knjige, knjiga.naslov AS \"Naslov knjige\", nastopa.id_osebe, oseba.ime FROM film
                     JOIN posnet_po ON film.id=posnet_po.id_filma
                     JOIN knjiga ON id_knjige=knjiga.id
                     JOIN nastopa ON film.id=nastopa.id_filma
                     JOIN oseba ON id_osebe=oseba.id
                     WHERE film.naslov = ", input$naslov, con=conn)
    data <- dbGetQuery(conn, sql)
    data[,]
    
  })  
  
  output$izbran.naslov <- DT::renderDataTable(DT::datatable({     #glavna tabela rezultatov
    najdi.film()
  }))
  output$izbran.naslov2<- renderText({
    stevilo <- count(najdi.film()) %>% pull()
    if (stevilo <= 0) {
      return("Izbran film ni posnet po nobeni knijigi!")
    }
  })
#-------------------------------------------------------------------------------------------------
  #zavihek iskanje po igralcih
  
  
  output$ui_igralec <- renderUI({
    sqlOutput_igralec <- dbGetQuery(conn, build_sql("SELECT ime FROM oseba", con = conn))
    
    textInput("igralec",
                label = "Izberite igralca:",
              "Lauren Bacall")
  }) 
  
  izberi.igralca1 <- reactive({
    validate(need(!is.null(input$igralec), "Izberite igralca:"))
    sql <- build_sql("SELECT film.naslov, film.leto FROM film 
                     JOIN nastopa ON film.id = nastopa.id_filma
                     JOIN oseba ON oseba.id = nastopa.id_osebe
                     WHERE oseba.ime = ", input$igralec, con = conn)
    data <- dbGetQuery(conn, sql)
    data[,]
  })
  
  output$izberi.igralca <- DT::renderDataTable({
    izberi.igralca1()
  })
  
#-------------------------------------------------------------------------------------------------
#zavihek iskanje po nagradah


#output$izbor.nagrade <- renderUI({
#  izbira_nagrade <- dbGetQuery(conn, build_sql("SELECT ", con = conn))
#  selectInput("Nagrada", label="Katerega oskarja zelite?",
#              choices = izbira_nagrade)
#})

najdi.nagrado<-reactive({
  validate(need(!is.null(input$Nagrada), "Izberi oskarja!"))
  if (input$Nagrada =="Nagrada igralca") {
    sql <- build_sql("SELECT nagrada.ime, kategorija, id_filma, film.naslov AS \"Naslov filma\" FROM nagrada
JOIN film ON id_filma=film.id
GROUP BY nagrada.ime, kategorija, id_filma, film.naslov, leto_nagrade
HAVING nagrada.leto_nagrade =", input$leto, con=conn)
  } else 
  {sql <- build_sql("SELECT nagrada.ime AS \"Ime nagrade\", kategorija, id_osebe, oseba.ime AS \"Ime osebe\" FROM nagrada
    JOIN oseba ON id_osebe=oseba.id
    GROUP BY nagrada.ime, kategorija, id_osebe, oseba.ime, leto_nagrade
    HAVING nagrada.leto_nagrade =", input$leto, con=conn)
}
  data <- dbGetQuery(conn, sql)
  data[,]
  
})  

output$izbrana.nagrada <- DT::renderDataTable(DT::datatable({     #glavna tabela rezultatov
  najdi.nagrado()
}))

#------------------------------------------------------------------------------------------------
  # zavihek zanr
  
  output$ui_zanr <- renderUI({
    sqlOutput_zanr <- dbGetQuery(conn, build_sql("SELECT ime FROM zanr", con = conn))
    selectInput(
      "Zanr",
      label = "Izberite zanr:",
      choices = sqlOutput_zanr
    )
  })
  
  izberi.zanr1 <- reactive({
    validate(need(!is.null(input$Zanr), "Izberite zanr:"))
    sql <- build_sql("SELECT film.naslov, film.leto FROM film 
                     JOIN ima ON film.id = ima.id_filma
                     JOIN zanr ON zanr.id = ima.id_zanra
                     WHERE zanr.ime = ", input$Zanr, con = conn)
    data <- dbGetQuery(conn, sql)
    data[,]
  })
  
  output$izberi.zanr <- DT::renderDataTable({
    izberi.zanr1()
  })
  
#------------------------------------------------------------------------------------------------
# zavihek: "Iskanje po letu izida"
  
  izberi_leto <- reactive({
    validate(need(!is.null(input$leto), "Izberite leto"))
    sql <- build_sql("SELECT film.naslov, film.leto, film.trajanje, zanr.ime AS zanr FROM film
                     JOIN ima ON ima.id_filma = film.id
                     JOIN zanr ON zanr.id = ima.id_zanra
                     WHERE film.leto BETWEEN ", input$leta[1], " AND ", input$leta[2],
                     " ORDER BY film.leto ASC", con = conn)
    data <- dbGetQuery(conn, sql)
    data[, ]
  })
  
  output$tabela_leto <- DT::renderDataTable({
    izberi_leto()
  })  
  
  #------------------------------------------------------------------------------------------------
  #zavihek komentiranja
  output$izbran.film <- renderUI({
    izbira_filma <- dbGetQuery(conn, build_sql("SELECT id,naslov FROM film ORDER BY naslov", con = conn))
    selectInput("film",
                label="Izberite film:",
                choices=setNames(izbira_filma$id,izbira_filma$naslov))
  })
  
  observeEvent(input$komentar_gumb,{
    sql2 <- build_sql("INSERT INTO ocena (uporabnik_id,ime, film_id, besedilo, ocena)
                      VALUES(",userID(),",",pridobi.ime.uporabnika(userID()),",",input$film,",",input$komentar,",",input$stevilka,")" , con = conn)
    data2 <- dbGetQuery(conn, sql2)
    data2
    shinyjs::reset("komentiranje") # reset po vpisu komentarja
    shinyjs::reset("ocena") #reset po vpisu ocene
  })
  
  
  
  najdi.komentar <- reactive({
    input$komentar_gumb
    validate(need(!is.null(input$film),"Izberite film:"))
    sql_komentar <- build_sql("SELECT ime AS \"Uporabnik\", besedilo AS \"Komentar\",ocena AS \"Ocena\" FROM ocena
                              WHERE film_id =",input$film, con = conn)
    komentarji <- dbGetQuery(conn, sql_komentar)
    validate(need(nrow(komentarji) > 0, "Ni komentarjev."))
    komentarji
    
  })
  
  output$komentiranje <- DT::renderDataTable(DT::datatable(najdi.komentar()))
}) 
