#Nalaganje tabel
library(readr)

data1 <- read_delim("U:/Podatki filmi/name.basics.tsv/data.tsv", 
                        "\t", escape_double = FALSE, trim_ws = TRUE)
#ta tabela je že okej

data2 <- read_delim("U:/Podatki filmi/title.akas.tsv/data.tsv", 
                        "\t", escape_double = FALSE, trim_ws = TRUE)
#data2 <- data2[, c(1,3,4)]


data3 <- read_delim("U:/Podatki filmi/title.basics.tsv/data.tsv", 
                  "\t", escape_double = FALSE, trim_ws = TRUE)

data4 <- read_delim("U:/Podatki filmi/title.crew.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE)

data5 <- read_delim("U:/Podatki filmi/title.episode.tsv/data.tsv", 
                   "\t", escape_double = FALSE, trim_ws = TRUE)

data6 <- read_delim("U:/Podatki filmi/title.principals.tsv/data.tsv", 
                    "\t", escape_double = FALSE, trim_ws = TRUE)

data7 <- read_delim("U:/Podatki filmi/title.ratings.tsv/data.tsv", 
                     "\t", escape_double = FALSE, trim_ws = TRUE)



