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
                    "\t", escape_double = FALSE, trim_ws = TRUE, na = "\\N")
stolpci<-c("id_os","Ime","leto_rojstva","leto_smrti","poklic","naslov_filma")
names(data1)<-stolpci
#ta tabela je ?e okej

#tabela oseba
oseba = data1[,c(1,2,3,4)]


#tabela, ki id_filma priredi ime filma
#data2 <- read_delim("U:/Podatki filmi/title.akas.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE)
#data2 <- data2[, c(1,3,4)]
#data2 <- subset(data2,region=="US")
#data2 <- data2[, c(1,2)]
#names(data2) <-c("id_film","naslov")
#data2 <- naslov


data3 <- read_delim("U:/Podatki filmi/title.basics.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE)
data3 <- data3[, c(1,2,3,4,6,8,9)]
data3 <- subset(data3,titleType=="movie")
data3 <- data3[,c(1,3,4,5,6,7)]



data4 <- read_delim("U:/Podatki filmi/title.crew.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE)



data6 <- read_delim("U:/Podatki filmi/title.principals.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE)
data6<-data6[,c(1,3,4)]
data6<-subset(data6, category=='writer'|category=='actor'|category=='director')


data7 <- read_delim("U:/Podatki filmi/title.ratings.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE)
data7 <- data7[,c(1,2)]


