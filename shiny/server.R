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


output$izbor.filma <- renderUI({
  
  izbira_filma = dbGetQuery(conn, build_sql("SELECT id, naslov FROM film ORDER BY naslov", con = conn))
  
  selectInput("naslov",
              label = "Izberite film:",
              choices = setNames(izbira_filma$id, izbira_filma$naslov)
  )
})

  najdi.film<-reactive({
    validate(need(!is.null(input$naslov), "Izberi film!"))
    sql <- build_sql("SELECT DISTINCT film.naslov  AS \"Naslov filma\"", input$sodelujoci, con=conn)
    data <- dbGetQuery(conn, sql)
    data
    
  })  
  
  output$sodel <- DT::renderDataTable(DT::datatable({     #glavna tabela rezultatov
    tabela=najdi.film()
  }))
#-------------------------------------------------------------------------------------------------
#zavihek iskanje po igralcih


output$izbor.igralec <- renderUI({
  
  izbira_igralec = dbGetQuery(conn, build_sql("SELECT id_osebe FROM nastopa", con = conn))
  
  selectInput("igralec",
              label = "Izberite igralca:",
              choices = setNames(izbira_igralec$id_osebe)
  )
}) 
  

#-------------------------------------------------------------------------------------------------
#zavihek iskanje po nagradah


output$izbor.nagrada <- renderUI({
  izbira_nagrade = dbGetQuery(conn, build_sql("SELECT id_filma, id FROM dobi", con = conn))
  
  selectInput("nagrada", label="Izberite oskarja:",
              choices = setNames(izbira_nagrade$id_filma, izbira_nagrade$id))
})

#------------------------------------------------------------------------------------------------
# zavihek zanr

output$ui_assetClass <- renderUI({
  sqlOutput_zanr <- dbGetQuery(conn, build_sql("SELECT ime FROM zanr", con = conn))
  selectInput(
    "Zanr",
    label = "Izberite zanr:",
    choices = sqlOutput_zanr
  )
})

#------------------------------------------------------------------------------------------------
#zavihek komentiranja


observeEvent(input$komentar_gumb,{
  ideja <- renderText({input$komentar})
  sql2 <- build_sql("INSERT INTO ocena (uporabnik_id, film_id, ocena)
                    VALUES(userID(), "," ,input$naslov,",", input$komentar)", con = conn)  
  data2 <- dbGetQuery(conn, sql2)
  data2
  shinyjs::reset("komentiranje") # reset po vpisu komentarja
})





najdi.komentar <- reactive({
  input$komentar_gumb
  sql_komentar <- build_sql("SELECT id AS \"Uporabnik\", ocena AS \"Ocena\" FROM ocena
                            WHERE film_id =",input$naslov, con = conn)
  komentarji <- dbGetQuery(conn, sql_komentar)
  validate(need(nrow(komentarji) > 0, "Ni komentarjev."))
  komentarji
  
})

output$komentiranje <- DT::renderDataTable(DT::datatable(najdi.komentar()))
}) 
