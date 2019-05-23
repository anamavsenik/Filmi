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
library(tidyr)

data1 <- read_delim("U:/Podatki filmi/name.basics.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE, na = "\\N", n_max=50000)
stolpci<-c("id_os","Ime","leto_rojstva","leto_smrti","poklic","naslov_filma")
names(data1)<-stolpci
#ta tabela je ?e okej


data33 <- read_delim("U:/Podatki filmi/title.basics.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE,n_max = 50000)
data3 <- subset(data33,titleType=="movie")
data3 <- data3[,c(3,6,8,9)]

data4 <- read_delim("U:/Podatki filmi/title.crew.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE,n_max=50000)



data6 <- read_delim("U:/Podatki filmi/title.principals.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE,n_max=50000)
data6<-data6[,c(1,3,4)]
data6<-subset(data6, category=='writer'|category=='actor'|category=='director')


data7 <- read_delim("U:/Podatki filmi/title.ratings.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE,n_max=50000)
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
zanri <- data.frame(ociscena3$primaryTitle,ociscena3$genres)
s<- strsplit(as.character(zanri$ociscena3.genres), split = ",")
zanri1<- data.frame(film=rep(zanri$ociscena3.primaryTitle,sapply(s,length)),ime_zanra=unlist(s))

imena_zanrov <- c()
for(zanr in zanri1$ime_zanra){
  if(!(zanr %in% imena_zanrov)){
    imena_zanrov=c(imena_zanrov, zanr)
  }
}
zanr_id <- c(1:length(imena_zanrov))
vsi_zanri=data.frame(id=zanr_id, ime=imena_zanrov)
vsi_zanri <- subset(vsi_zanri, vsi_zanri$ime!='\\N')


#tabela, ki prikazuje filme in njihove žanre, povezava - tabela IMA
colnames(zanri) <- c("film", "ime_zanra")
ima1 <- merge(zanri1, filmi, by.x = "film", by.y="naslov", all.x = TRUE)
ima2 <- merge(ima1, vsi_zanri, by.x = "ime_zanra", by.y = "ime", all.x= TRUE)
ima2[is.na(ima2)] <- "neznano" 
ima<- ima2[,c(3,6)]
colnames(ima) <- c("id_filma", "id_zanra")

#tabela, ki povezuje osebe in filme, povezava - tabela NASTOPA
#zopet preèistimo, enako kot pri žanrih:
nastopi_v_filmih <- data.frame(ociscena1$Ime,ociscena1$naslov_filma)
s<- strsplit(as.character(nastopi_v_filmih$ociscena1.naslov_filma), split = ",")
nastopi_v_filmih1<- data.frame(oseba=rep(nastopi_v_filmih$ociscena1.Ime,sapply(s,length)),naslov=unlist(s))

nastop1 <- merge(data33, nastopi_v_filmih1, by.x="tconst", by.y="naslov", all.x=TRUE)
nastop2 <- merge(nastop1, filmi, by.x="primaryTitle", by.y="naslov", all.x=TRUE)
nastop3 <- merge(nastop2, sodelujoci, by.x="oseba", by.y="ime", all.x=TRUE)
nastopa <- nastop3[,c(11,14)]
colnames(nastopa)<-c("id_filma", "id_osebe")

