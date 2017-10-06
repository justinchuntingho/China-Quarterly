# What is China Afraid of?
Justin Ho  
8/19/2017  



On 18 August, China Quarterly was forced by China to remove 300 articles on its China site. I scraped all the available abstracts of articles and condcuted a simple text analysis in order to find out what is China so afraid of. The full list can be found [here](https://www.cambridge.org/core/services/aop-file-manager/file/59970028145fd05f66868bf5). 

## Web Scraping
The codes I used to scrape the abstracts.

```r
library(rvest)
library(magrittr)
library(stringr)

list <- readLines("list.txt")
list <- paste(list, collapse=' ')
list <- unlist(strsplit(list, " Published online", fixed = TRUE))
links <- str_extract(list, "https://doi.org/10.1017/S[0-9X]*")
links <- links[-318]

df <- c()
for (i in 1:length(links)){
  tryCatch({
  ab <- read_html(links[i])
  title <- ab %>% html_node(xpath = "//*[@id=\"Top\"]/div/div[1]/h1") %>% html_text()
  abtext <- ab %>% html_node(xpath = "//*[@id=\"Top\"]/div/div[2]/div[1]/div[2]/div[2]/div/div/p") %>% html_text()
  }, error=function(e){title <- "Error"
  abtext <- "Error"})
  df <- rbind(df, c(title,abtext))
}
df <- as.data.frame(df)
rownames(df) <- 1:length(df[,1])
colnames(df) <- c("Title", "Text")
write.csv(df, file ="abstract.csv", row.names = FALSE, fileEncoding = "UTF-8")
```

## Text Analysis
Loading the required packages.

```r
require(readtext)
require(quanteda)
require(magrittr)
library(wordcloud)
set.seed(1024)
```

Creating a corpus with the abstracts.

```r
abs <- corpus(readtext("abstract edited.csv", text_field = "Text"))
docnames(abs) <- docvars(abs)$Title
```

A Document-Feature Martix is created.

```r
abstokens <- tokens(abs, remove_punct = TRUE, remove_numbers = TRUE, verbose = FALSE, remove_url = TRUE)
absdfm <- dfm(abstokens, remove = c(stopwords('english'), "na")) %>% 
  dfm_trim(min_doc = 5, min_count = 10) %>% 
  dfm_weight(type = 'tfidf')
```

Showing the 24 most frequently appeared features.

```r
topfeatures(absdfm, 24)
```

```
##    chinese revolution  political   cultural      china      party 
##   92.13836   82.07473   77.71232   77.48064   70.54096   62.87452 
##     taiwan        one  communist      state      falun      local 
##   61.42696   45.76422   45.50319   45.38794   44.16348   40.73604 
##   economic        new       gong   movement        mao      since 
##   40.16857   40.16857   39.59485   38.44462   38.39185   37.90688 
##    china's        two       also      power    article      tibet 
##   36.53004   36.53004   36.42708   36.19803   35.10112   34.07945
```

Visualising the result. A very brief analysis shows that it seems Cultural Revolution, Taiwan, Falun Gong, Political Movement, Mao and Tibet are the themes that terrify China the most.


```r
textplot_wordcloud(absdfm, min.freq = 1, random.order = FALSE,
                   rot.per = .1, 
                   colors = RColorBrewer::brewer.pal(4,"Dark2"))
```

<img src="README_files/figure-html/cloud-1.png" style="display: block; margin: auto;" />

