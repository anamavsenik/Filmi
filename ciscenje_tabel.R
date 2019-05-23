#Nalaganje tabel
library(readr)
library(dplyr)
library(gsubfn)
library(ggplot2)
library(XML)
library(eeptools)
library(labeling)
library(rvest)
library(extrafont)

data1 <- read_delim("U:/Podatki filmi/name.basics.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE, na = "\\N", n_max=30)
stolpci<-c("id_os","Ime","leto_rojstva","leto_smrti","poklic","naslov_filma")
names(data1)<-stolpci
#ta tabela je ?e okej


data3 <- read_delim("U:/Podatki filmi/title.basics.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE,n_max = 200)
data3 <- subset(data3,titleType=="movie")
data3 <- data3[,c(3,6,8,9)]



data4 <- read_delim("U:/Podatki filmi/title.crew.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE,n_max=30)



data6 <- read_delim("U:/Podatki filmi/title.principals.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE,n_max=30)
data6<-data6[,c(1,3,4)]
data6<-subset(data6, category=='writer'|category=='actor'|category=='director')


data7 <- read_delim("U:/Podatki filmi/title.ratings.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE,n_max=30)
data7 <- data7[,c(1,2)]


Top_Movies_Based_on_Books_1 <- read_csv("//spin/HabjanN16$/_System/MyDocuments/Top Movies Based on Books-1.csv")


#funkcija za brisanje nepopolnih vrstic
delete.na <- function(DF, n=0) {
  DF[rowSums(is.na(DF)) <= n,]
}

ociscena1 <- delete.na(data1)
ociscena3 <- delete.na(data3)
ociscena4 <- delete.na(data4)
ociscena6<- delete.na(data6)
ociscena7 <- delete.na(data7)

#posamezne tabele, kako bodo izgledale

#tabela osebe, ki sodelujejo v filmu
sodelujoc_id <- c(1:length(ociscena1$Ime))
sodelujoci=data.frame(id=sodelujoc_id, ime=ociscena1$Ime,leto_rojstva=ociscena1$leto_rojstva)

#tabela filmi, ki prikazuje naslove filmov, èas trajanja, leto 
filmi_id<- c(1:length(ociscena3$primaryTitle))
filmi=data.frame(id=filmi_id,naslov=ociscena3$primaryTitle,leto=ociscena3$startYear,trajanje=ociscena3$runtimeMinutes)

#tabela, ki prikazuje žanre


