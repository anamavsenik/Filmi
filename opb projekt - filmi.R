library(readr)
memory.limit(16384)
data1 <- read_delim("C:/Users/Neža/Downloads/name.basics.tsv.gz",
                                "\t", escape_double = FALSE, trim_ws = TRUE, na = "\\N", n_max=50000)
stolpci<-c("id_os","Ime","leto_rojstva","leto_smrti","poklic","naslov_filma")
names(data1)<-stolpci

data33<- read_delim("C:/Users/Neža/Downloads/title.basics.tsv.gz", 
                    "\t", escape_double = FALSE, trim_ws = TRUE, na = "\\N", n_max=50000)
data3 <- subset(data33,titleType=="movie")
data3 <- data3[,c(3,6,8,9)]

data4 <- read_delim("C:/Users/Neža/Downloads/title.crew.tsv.gz", 
                    "\t", escape_double = FALSE, trim_ws = TRUE, na = "\\N", n_max=50000)

data6 <- read_delim("C:/Users/Neža/Downloads/title.principals.tsv.gz", 
                    "\t", escape_double = FALSE, trim_ws = TRUE, na = "\\N", n_max=50000)
data6<-data6[,c(1,3,4)]
data6<-subset(data6, category=='writer'|category=='actor'|category=='director')

data7 <- read_delim("C:/Users/Neža/Downloads/title.ratings.tsv.gz", 
                    "\t", escape_double = FALSE, trim_ws = TRUE, na = "\\N", n_max=50000)
data7 <- data7[,c(1,2)]

data8 <- read.csv("knjige.csv")
data8 <- data8[, c(1, 2, 6)]
knjiga_id <- c(1 : length(data8$Position))
knjiga <- data.frame(id = knjiga_id, naslov = data8$Title)


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
oseba<-sodelujoci


#tabela filmi, ki prikazuje naslove filmov, ?as trajanja, leto 
filmi_id<- c(1:length(ociscena3$primaryTitle))
filmi=data.frame(id=filmi_id,naslov=ociscena3$primaryTitle,leto=ociscena3$startYear,trajanje=ociscena3$runtimeMinutes)
film<-filmi
film$trajanje[film$trajanje == '\\N'] <- NA

#tabela, ki prikazuje ?anre
zanri <- data.frame(ociscena3$primaryTitle,ociscena3$genres)
s<- strsplit(as.character(zanri$ociscena3.genres), split = ",")
zanri1<- data.frame(film=rep(zanri$ociscena3.primaryTitle,sapply(s,length)),ime_zanra=unlist(s))

imena_zanrov <- c()
for(zanr in zanri1$ime_zanra){
  if(!(zanr %in% imena_zanrov)){
    imena_zanrov=c(imena_zanrov, zanr)
  }
}
imena_zanrov <- c(imena_zanrov, "neznano")
zanr_id <- c(1:length(imena_zanrov))
vsi_zanri=data.frame(id=zanr_id, ime=imena_zanrov)
vsi_zanri <- subset(vsi_zanri, vsi_zanri$ime!='\\N')
zanr<-vsi_zanri


#tabela, ki prikazuje filme in njihove ?anre, povezava - tabela IMA
colnames(zanri) <- c("film", "ime_zanra")
ima1 <- merge(zanri1, filmi, by.x = "film", by.y="naslov", all.x = TRUE)
ima2 <- merge(ima1, vsi_zanri, by.x = "ime_zanra", by.y = "ime", all.x= TRUE)
ima2[is.na(ima2)] <- 27
ima<- ima2[,c(3,6)]
colnames(ima) <- c("id_filma", "id_zanra")
ima <- ima[!duplicated(ima), ]

#tabela, ki povezuje osebe in filme, povezava - tabela NASTOPA
#zopet pre?istimo, enako kot pri ?anrih:
nastopi_v_filmih <- data.frame(ociscena1$Ime,ociscena1$naslov_filma)
s<- strsplit(as.character(nastopi_v_filmih$ociscena1.naslov_filma), split = ",")
nastopi_v_filmih1<- data.frame(oseba=rep(nastopi_v_filmih$ociscena1.Ime,sapply(s,length)),naslov=unlist(s))

nastop1 <- merge(data33, nastopi_v_filmih1, by.x="tconst", by.y="naslov", all.x=TRUE)
nastop2 <- merge(nastop1, filmi, by.x="primaryTitle", by.y="naslov", all.x=TRUE)
nastop3 <- merge(nastop2, sodelujoci, by.x="oseba", by.y="ime", all.x=TRUE)
nastopa <- nastop3[,c(11,14)]
colnames(nastopa)<-c("id_filma", "id_osebe")
nastopa <- subset(nastopa, nastopa$id_filma != "NA")
# se brisanje dvojnih podatkov in brisanje vrstic z NA:
nastopa <- nastopa[!duplicated(nastopa), ]
nastopa <- nastopa[rowSums(is.na(nastopa)) <= 0, ]

#pre?istimo tabelo oskarjev
oskarji <- read.csv("oskarji.csv")
oskarji <- subset(oskarji, oskarji$winner=="True")

oskarji <- merge(oskarji, sodelujoci, by.x="entity", by.y="ime", all.x=TRUE)
oskarji <- merge(oskarji, filmi, by.x="entity", by.y="naslov", all.x=TRUE)
names(oskarji)<-c("ime", "leto_nagrade", "kategorija", "zmaga", "id_osebe", "leto_rojstva", "id_filma", "leto_filma", "trajanje")
id_nagrade <- c(1:length(oskarji$ime))
nagrada=data.frame(id=id_nagrade, oskarji)


#tabela nosilec, ki povezuje indekse igralcev in nagrad - tabela NOSILEC
oskarji_osebe <- subset(nagrada, nagrada$id_osebe!="NA")
oskarji_osebe <- oskarji_osebe[,c(1,6)]
nosilec<-oskarji_osebe

#tabela DOBI, povezuje indekse filmov in nagrad
oskarji_filmi <- subset(nagrada, nagrada$id_filma!="NA")
oskarji_filmi <- subset(oskarji_filmi, oskarji_filmi$leto_nagrade==oskarji_filmi$leto_filma)
oskarji_filmi <- merge(oskarji_filmi, nagrada, by.x = "id", by.y = "leto_nagrade")
oskarji_filmi <- merge(oskarji_filmi, nagrada, by.x = "id", by.y = "kategorija")
oskarji_filmi <- oskarji_filmi[,c(1,8)] ##katere stolpce naj vzamem??
dobi<-oskarji_filmi

# tabela, ki povezuje filme z knjigami, povezava - tabela POSNET PO
# problem v tabeli film: en film ima vec id
pomozna <- filmi[, c(1, 2)]
posnet_po <- merge(pomozna, knjiga, by.x = "naslov", by.y = "naslov")
posnet_po <- posnet_po[, c(2, 3)]
colnames(posnet_po) <- c("id_filma", "id_knjige")

# popravki, potrebno?
nagrada <- nagrada[, c(1:6, 8)]






















