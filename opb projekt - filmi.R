library(readr)
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

#memory.limit(16384)
data6 <- read_delim("C:/Users/Neža/Downloads/title.principals.tsv.gz", 
                    "\t", escape_double = FALSE, trim_ws = TRUE, na = "\\N", n_max=50000)
data6<-data6[,c(1,3,4)]
data6<-subset(data6, category=='writer'|category=='actor'|category=='director')

data7 <- read_delim("C:/Users/Neža/Downloads/title.ratings.tsv.gz", 
                    "\t", escape_double = FALSE, trim_ws = TRUE, na = "\\N", n_max=50000)
data7 <- data7[,c(1,2)]
