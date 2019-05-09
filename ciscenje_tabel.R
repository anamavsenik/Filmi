#Nalaganje tabel
library(readr)

data1 <- read_delim("U:/Podatki filmi/name.basics.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE)
#ta tabela je e okej



data2 <- read_delim("U:/Podatki filmi/title.akas.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE)
data2 <- data2[, c(1,3,4)]
data2 <- subset(data2,region=="US")
data2 <- data2[, c(1,2)]



data3 <- read_delim("U:/Podatki filmi/title.basics.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE)
data3 <- data3[, c(1,2,3,4,6,8,9)]
data3 <- subset(data3,titleType=="movie")
data3 <- data3[,c(1,3,4,5,6,7)]



data4 <- read_delim("U:/Podatki filmi/title.crew.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE)



data6 <- read_delim("U:/Podatki filmi/title.principals.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE)


data7 <- read_delim("U:/Podatki filmi/title.ratings.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE)
data7 <- data7[,c(1,2)]


