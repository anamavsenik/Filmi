 # Neposredno klicanje SQL ukazov v R
library(RPostgreSQL)
library(dplyr)
library(dbplyr)

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
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS knjiga CASCADE",con = conn))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS nastopa CASCADE",con = conn))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS nosilec CASCADE",con = conn))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS dobi CASCADE",con = conn))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS ima CASCADE",con = conn))
    dbSendQuery(conn,build_sql("DROP TABLE IF EXISTS posnet_po CASCADE",con = conn))
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
                                           kategorija text NOT NULL,
                                           zmaga text NOT NULL,
                                           id_osebe INTEGER REFERENCES oseba(id),
                                           id_filma INTEGER REFERENCES film(id))", con = conn))
      
      knjiga <- dbSendQuery(conn, build_sql("CREATE TABLE knjiga(
                                          id INTEGER PRIMARY KEY,
                                          naslov text NOT NULL)", con = conn))
      
      #tabele vmesnih relacij
      nastopa <- dbSendQuery(conn, build_sql("CREATE TABLE nastopa(
                                             id_filma INTEGER NOT NULL REFERENCES film(id),
                                             id_osebe INTEGER NOT NULL REFERENCES oseba(id),
                                             PRIMARY KEY (id_filma, id_osebe))", con = conn))
      
      nosilec <- dbSendQuery(conn, build_sql("CREATE TABLE nosilec(
                                             id INTEGER NOT NULL REFERENCES nagrada(id),
                                             id_osebe INTEGER NOT NULL REFERENCES oseba(id),
                                             PRIMARY KEY(id, id_osebe))", con = conn))
      
      dobi <- dbSendQuery(conn, build_sql("CREATE TABLE dobi(
                                          id INTEGER NOT NULL REFERENCES nagrada(id),
                                          id_filma INTEGER REFERENCES film(id),
                                          PRIMARY KEY(id, id_filma))", con = conn))
      
      ima <- dbSendQuery(conn, build_sql("CREATE TABLE ima(
                                         id_filma INTEGER NOT NULL REFERENCES film(id),
                                         id_zanra INTEGER NOT NULL REFERENCES zanr(id),
                                         PRIMARY KEY(id_filma, id_zanra))", con = conn))
      
      posnet_po <- dbSendQuery(conn, build_sql("CREATE TABLE posnet_po(
                                              id_filma INTEGER NOT NULL REFERENCES film(id),
                                              id_knjige INTEGER NOT NULL REFERENCES knjiga(id),
                                              PRIMARY KEY(id_filma, id_knjige))", con = conn))
      
      uporabniki <- dbSendQuery(conn, build_sql("CREATE TABLE IF NOT EXISTS uporabniki (
                                               id SERIAL PRIMARY KEY,
                                               username text NOT NULL UNIQUE,
                                               hash text NOT NULL)", con = conn))
      
      ocena <- dbSendQuery(conn, build_sql("CREATE TABLE IF NOT EXISTS ocena (
                                           id SERIAL PRIMARY KEY,
                                           uporabnik_id INTEGER,
                                           ime TEXT,
                                           film_id INTEGER,
                                           besedilo TEXT,
                                           ocena INTEGER,
                                           FOREIGN KEY(film_id) REFERENCES film(id),
                                           FOREIGN KEY(uporabnik_id) REFERENCES uporabniki(id))", con = conn))
      
      
      
      
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
      dbWriteTable(conn, name="knjiga", knjiga, append=T, row.names=FALSE)
      dbWriteTable(conn, name="nastopa", nastopa, append=T, row.names=FALSE)
      dbWriteTable(conn, name="ima", ima, append=T, row.names=FALSE)
      dbWriteTable(conn, name="nosilec", nosilec, append=T, row.names=FALSE)
      dbWriteTable(conn, name="dobi", dobi, append=T, row.names=FALSE)
      dbWriteTable(conn, name="posnet_po", posnet_po, append=T, row.names=FALSE)
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

