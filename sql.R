 # Neposredno klicanje SQL ukazov v R
library(RPostgreSQL)
library(dplyr)
library(dbplyr)

source("auth_public.R",encoding="UTF-8")
source("ciscenje_tabel.R", encoding="UTF-8")
source("auth.R", encoding="UTF-8")

# Povežemo se z gonilnikom za PostgreSQL
drv <- dbDriver("PostgreSQL")


# Funkcija za brisanje tabel
delete_table <- function(){
  # Uporabimo funkcijo tryCatch,
  # da prisilimo prekinitev povezave v primeru napake
  tryCatch({
    # Vzpostavimo povezavo z bazo
    
    conn <- dbConnect(drv, dbname = db, host = host, user = user, password = password)
    # ?e tabela obstaja, jo zbri?emo, ter najprej zbri?emo tiste,
    # ki se navezujejo na druge
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS oseba CASCADE",con = conn))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS film CASCADE",con = conn))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS zanr CASCADE",con = conn))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS nagrada CASCADE",con = conn))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS nastopa CASCADE",con = conn))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS nosilec CASCADE",con = conn))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS ima CASCADE",con = conn))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS uporabniki CASCADE",con = conn))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS ocena CASCADE",con = conn))
  }, finally = {
    dbDisconnect(conn)
  })
}



  #Funkcija, ki ustvari tabele
  create_table <- function(){
    # Uporabimo tryCatch (da se pove?emo in bazo in odve?emo)
    # da prisilimo prekinitev povezave v primeru napake
    tryCatch({
      conn <- dbConnect(drv, dbname = db, host = host, user = user, password = password)
      # Vzpostavimo povezavo
      
      #Dve prazni tabeli za uporabnike
     
      # Glavne tabele
      oseba <- dbSendQuery(conn, build_sql("CREATE TABLE oseba (
                                               id INTEGER PRIMARY KEY, 
                                               ime text NOT NULL,
                                               leto_rojstva INTEGER)", con = conn))
      
      film <- dbSendQuery(conn, build_sql("CREATE TABLE film(
                                           id INTEGER PRIMARY KEY,
                                           naslov text NOT NULL,
                                           leto INTEGER,
                                           trajanje text)", con = conn))
      
      zanr <- dbSendQuery(conn, build_sql("CREATE TABLE zanr(
                                           id INTEGER PRIMARY KEY,
                                           ime text NOT NULL)", con = conn))
      
      nagrada <- dbSendQuery(conn, build_sql("CREATE TABLE nagrada(
                                           id INTEGER PRIMARY KEY,
                                           ime text NOT NULL,
                                           leto_nagrade INTEGER NOT NULL,
                                           kategorija text NOT NULL ,
                                          zmaga text,
                                             id_osebe text,
                                             leto_rojstva text,
                                             id_filma text,
                                             leto_filma text,
                                             trajanje text)" , con = conn))
      
      
      #tabele vmesnih relacij
      nastopa <- dbSendQuery(conn, build_sql("CREATE TABLE nastopa(
                                             id_filma INTEGER REFERENCES film(id),
                                             id_osebe INTEGER REFERENCES oseba(id),
                                             (id_filma, id_osebe) PRIMARY KEY)",con = conn))
      
      
      nosilec <- dbSendQuery(conn, build_sql("CREATE TABLE nosilec(
                                             id_oseba INTEGER REFERENCES oseba(id),
                                             id_nagrada INTEGER REFERENCES nagrada(id),
                                             (id_oseba, id_nagrada) PRIMARY KEY)",con = conn))
      
      ima <- dbSendQuery(conn, build_sql("CREATE TABLE ima(
                                         id_zanra INTEGER REFERENCES zanr(id),
                                         id_filma INTEGER REFERENCES film(id),
                                         (id_zanra, id_filma) PRIMARY KEY)",con = conn))
      
      
      uporabniki <- dbSendQuery(conn, build_sql("CREATE TABLE uporabniki (
                                               id SERIAL PRIMARY KEY,
                                                username text NOT NULL,
                                                username UNIQUE,
                                                hash text NOT NULL)",con = conn))
      
      ocena <- dbSendQuery(conn, build_sql("CREATE TABLE ocena (
                                           id SERIAL PRIMARY KEY,
                                           uporabnik_id INTEGER,
                                          uporabnik_id REFERENCES uporabniki(id),
                                           film_id INTEGER,
                                           FOREIGN KEY(film_id) REFERENCES film(id),
                                           ocena INTEGER)
                                           ",con = conn))
      
      
      
      
      dbSendQuery(conn, build_sql("GRANT ALL ON ALL TABLES IN SCHEMA public TO nezah WITH GRANT OPTION",con = conn))
      dbSendQuery(conn, build_sql("GRANT ALL ON ALL TABLES IN SCHEMA public TO stefandj WITH GRANT OPTION",con = conn))
      dbSendQuery(conn, build_sql("GRANT ALL ON ALL TABLES IN SCHEMA public TO anamarijak WITH GRANT OPTION",con = conn))
      
      dbSendQuery(conn, build_sql("GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO nezah WITH GRANT OPTION",con = conn))
      dbSendQuery(conn, build_sql("GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO stefandj WITH GRANT OPTION",con = conn))
      dbSendQuery(conn, build_sql("GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anamarijak WITH GRANT OPTION",con = conn))
      
      dbSendQuery(conn, build_sql("GRANT CONNECT ON DATABASE sem2019_anamarijak TO javnost",con = conn))
      dbSendQuery(conn, build_sql("GRANT SELECT ON ALL TABLES IN SCHEMA public TO javnost",con = conn))
      
    }, finally = {
      # Na koncu nujno prekinemo povezavo z bazo,
      # saj preve? odprtih povezav ne smemo imeti
      dbDisconnect(conn) #PREKINEMO POVEZAVO
      # Koda v finally bloku se izvede, preden program kon?a z napako
    })
  }
  
  
  insert_data <- function(){
    tryCatch({
      conn <- dbConnect(drv, dbname = db, host = host, user = user, password = password)
      
      dbWriteTable(conn, name="film", film, append=T, row.names=FALSE)
      dbWriteTable(conn, name="oseba", oseba, append=T, row.names=FALSE)
      dbWriteTable(conn, name="zanr", zanr, append=T, row.names=FALSE)
      dbWriteTable(conn, name="nagrada", nagrada, append=T, row.names=FALSE)
      dbWriteTable(conn, name="nastopa", nastopa, append=T, row.names=FALSE)
      dbWriteTable(conn, name="ima", ima, append=T, row.names=FALSE)
      dbWriteTable(conn, name="nosilec", nosilec, append=T, row.names=FALSE)
    }, finally = {
      dbDisconnect(conn) 
      
    })
  }
  
  pravice <- function(){
    # Uporabimo tryCatch,(da se pove?emo in bazo in odve?emo)
    # da prisilimo prekinitev povezave v primeru napake
    tryCatch({
      # Vzpostavimo povezavo
      conn <- dbConnect(drv, dbname = db, host = host,#drv=s ?im se povezujemo
                        user = user, password = password)
      
      dbSendQuery(conn, build_sql("GRANT CONNECT ON DATABASE sem2019_anamarijak TO nezah WITH GRANT OPTION",con = conn))
      dbSendQuery(conn, build_sql("GRANT CONNECT ON DATABASE sem2019_anamarijak TO stefandj WITH GRANT OPTION",con = conn))
      
      dbSendQuery(conn, build_sql("GRANT ALL ON SCHEMA public TO stefandj WITH GRANT OPTION",con = conn))
      dbSendQuery(conn, build_sql("GRANT ALL ON SCHEMA public TO nezah WITH GRANT OPTION",con = conn))
      
      dbSendQuery(conn, build_sql("GRANT ALL ON ALL TABLES IN SCHEMA public TO stefandj WITH GRANT OPTION",con = conn))
      dbSendQuery(conn, build_sql("GRANT ALL ON ALL TABLES IN SCHEMA public TO nezah WITH GRANT OPTION",con = conn))
      dbSendQuery(conn, build_sql("GRANT ALL ON ALL TABLES IN SCHEMA public TO anamarijak WITH GRANT OPTION",con = conn))
      
      dbSendQuery(conn, build_sql("GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO stefandj WITH GRANT OPTION",con = conn))
      dbSendQuery(conn, build_sql("GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO nezah WITH GRANT OPTION",con = conn))
      dbSendQuery(conn, build_sql("GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anamarijak WITH GRANT OPTION",con = conn))
      
      dbSendQuery(conn, build_sql("GRANT CONNECT ON DATABASE sem2019_anamarijak TO javnost",con = conn))
      dbSendQuery(conn, build_sql("GRANT INSERT ON ALL TABLES IN SCHEMA public TO javnost",con = conn))
      dbSendQuery(conn, build_sql("GRANT SELECT ON ALL TABLES IN SCHEMA public TO javnost",con = conn))
      
      
      
    }, finally = {
      # Na koncu nujno prekinemo povezavo z bazo,
      # saj preve? odprtih povezav ne smemo imeti
      dbDisconnect(conn) #PREKINEMO POVEZAVO
      # Koda v finally bloku se izvede, preden program kon?a z napako
    })
  }
  
pravice()
delete_table()
create_table()
insert_data()
