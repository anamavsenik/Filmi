
sign.up.user <- function(username, pass){
  # Return values:
  # 1 ... success
  # 0 ... error
  # -10 ... username exists
  success <- 0      # Boolean, if the insertion into the db was successful
  
  # hashing of password
  pass <- hashpw(pass)
  clan <- username
  
  useraccount <- data.frame(username = clan, password=pass)
  uporabnikID <- NULL
  
  tryCatch({
    drv <- dbDriver("PostgreSQL")
    conn <- dbConnect(drv, dbname = db, host = host, user = user, password = password)
    userTable <- tbl(conn, "uporabniki")
    # Pogledamo, ce je uporabnisko ime ze zasedeno
    if(0 != dim((userTable %>% filter(username == clan) %>% collect()))[1]){
      success <- -10
    }
    # Ce nam if stavek vrne True, potem v bazo uporabnik dodamo uporabnika z zaporedno stevilko, uporabniskim in geslom
    sql_prijava <- build_sql("INSERT INTO uporabniki(username,hash)
                             VALUES(",clan,",",pass,") RETURNING id", con = conn)
    uporabnikID <- dbGetQuery(conn,sql_prijava)[[1]]
    success <- 1
  }, finally = {
    dbDisconnect(conn)
    return(list(success, uporabnikID))
  })
}

sign.in.user <- function(username, pass){
  # Return a list. In the first place is an indicator of success:
  # 1 ... success
  # 0 ... error
  # -10 ... wrong username
  # The second place represents the userid if the login info is correct,
  # otherwise it's NULL
  success <- 0
  uporabnikID <- NULL
  tryCatch({
    drv <- dbDriver("PostgreSQL")
    conn <- dbConnect(drv, dbname = db, host = host, user = user, password = password)
    userTable <- tbl(conn, "uporabniki")
    obstoj <- 0
    # obstoj = 0, ce username in geslo ne obstajata,  1 ce obstaja
    uporabnik <- username
    geslo <- pass
    hashGesla <- (userTable %>% filter(username == uporabnik) %>% collect() %>% pull(hash))[[1]]
    if(checkpw(geslo, hashGesla)){
      obstoj <- 1
    }
    if(obstoj == 0){
      success <- -10
    }else{
      uporabnikID <- (userTable %>% filter(username == uporabnik) %>%
                        collect() %>% pull(id))[[1]]
      success <- 1
    }
  },warning = function(w){
    print(w)
  },error = function(e){
    print(e)
  }, finally = {
    dbDisconnect(conn)
    return(list(success, uporabnikID))
  })
}

pridobi.ime.uporabnika <- function(userID){
  # Pridobi ime vpisanega glede na userID
  tryCatch({
    drv <- dbDriver("PostgreSQL")
    conn <- dbConnect(drv, dbname = db, host = host, user = user, password = password)
    sqlInput<- build_sql("SELECT username FROM uporabniki WHERE id=",userID, con = conn)
    userid <- dbGetQuery(conn, sqlInput)
  },finally = {
    dbDisconnect(conn)
    return(unname(unlist(userid)))
  }
  )
}
