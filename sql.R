# Neposredno klicanje SQL ukazov v R
library(dplyr)
library(dbplyr)
library(RPostgreSQL)

source("auth_public.R",encoding="UTF-8")
source("ciscenje_tabel.R", encoding="UTF-8")

# Pove≈æemo se z gonilnikom za PostgreSQL
drv <- dbDriver("PostgreSQL")

# Funkcija za brisanje tabel
delete_table <- function(){
    # Uporabimo funkcijo tryCatch,
    # da prisilimo prekinitev povezave v primeru napake
    tryCatch({
      # Vzpostavimo povezavo z bazo
      conn <- dbConnect(drv, dbname = db, host = host, user = user, password = password)
      
      # »e tabela obstaja, jo zbriöemo, ter najprej zbriöemo tiste,
      # ki se navezujejo na druge
      dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS oseba CASCADE"))
      dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS film CASCADE"))
      dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS zanr CASCADE"))
      dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS nastopa CASCADE"))
      dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS nagrada CASCADE"))
      dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS nosilec CASCADE"))
      dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS dobi CASCADE"))
   
    }, finally = {
      dbDisconnect(conn)
    })
  }
  
  
  #Funkcija, ki ustvari tabele
  create_table <- function(){
    # Uporabimo tryCatch (da se poveûemo in bazo in odveûemo)
    # da prisilimo prekinitev povezave v primeru napake
    tryCatch({
      # Vzpostavimo povezavo
      conn <- dbConnect(drv, dbname = db, host = host, user = user, password = password)
      
      # Glavne tabele
      oseba <- dbSendQuery(conn, build_sql("CREATE TABLE oseba (
                                               id INTEGER PRIMARY KEY, 
                                               ime text NOT NULL)"))
      
      film <- dbSendQuery(conn, build_sql("CREATE TABLE film(
                                           id INTEGER PRIMARY KEY,
                                           naslov text NOT NULL)"))
      
      zanr <- dbSendQuery(conn, build_sql("CREATE TABLE zanr(
                                           id INTEGER PRIMARY KEY,
                                           ime text NOT NULL)"))
      
      nagrada <- dbSendQuery(conn, build_sql("CREATE TABLE nagrada(
                                           id INTEGER PRIMARY KEY,
                                           ime text NOT NULL,
                                           leto_nagrade INTEGER NOT NULL,
                                           kategorija text NOT NULL )"))
      
    
      
    }, finally = {
      # Na koncu nujno prekinemo povezavo z bazo,
      # saj preveË odprtih povezav ne smemo imeti
      dbDisconnect(conn) #PREKINEMO POVEZAVO
      # Koda v finally bloku se izvede, preden program konËa z napako
    })
  }
  
  pravice()
  delete_table()
  create_table()
  insert_data()
  
  #con <- src_postgres(dbname = db, host = host, user = user, password = password)  
