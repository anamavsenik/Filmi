library(shiny)
library(dplyr)
library(RPostgreSQL)

source("../auth_public.R")

shinyServer(function(input, output) {
  # Vzpostavimo povezavo
  conn <- src_postgres(dbname = db, host = host,
                       user = user, password = password)
  
  # Povežemo se s tabelami, ki jih bomo rabili
  
  tbl.film <- tbl(conn, "film")
  tbl.zanr <- tbl(conn, "zanr")
  tbl.oseba <- tbl(conn, "oseba")
  tbl.knjiga <- tbl(conn, "knjiga")
  tbl.nastopa <- tbl(conn, "nastopa")
  tbl.ima <- tbl(conn, "ima")
  tbl.posnet_po <- tbl(conn, "posnet_po")
  tbl.nosilec <- tbl(conn, "nosilec")
  tbl.dobi <- tbl(conn, "dobi")
  tbl.nagrada <- tbl(conn, "nagrada")
 
  
  
})

  