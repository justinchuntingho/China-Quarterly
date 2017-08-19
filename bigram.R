require(readtext)
require(quanteda)
require(magrittr)
library(wordcloud)
set.seed(1024)

abs <- corpus(readtext("abstract edited.csv", textfield = "Text"))
docnames(abs) <- docvars(abs)$Title

abstokens <- tokens(abs, remove_punct = TRUE, remove_numbers = TRUE, verbose = FALSE, remove_url = TRUE, ngrams = 2)
absdfm <- dfm(abstokens, remove = c(stopwords('english'), "na")) %>% 
  dfm_trim(min_doc = 2, min_count = 2) %>% 
  dfm_weight(type = 'tfidf')


topfeatures(absdfm, 24)
featnames(absdfm)

### Remove features with stopwords

bad_features <- featnames(absdfm)[(stringr::str_detect(featnames(absdfm), paste0("_(", paste(stopwords('english'), collapse = "|"), ")$")) | stringr::str_detect(featnames(absdfm), paste0("^(", paste(stopwords('english'), collapse = "|"), ")_")) | stringr::str_detect(featnames(absdfm), "'s$"))]

png("bigram.png")
dfm_remove(absdfm, bad_features) %>% textplot_wordcloud(min.freq = 5, random.order = FALSE, rot.per = .0, colors = RColorBrewer::brewer.pal(7,"Dark2"))
dev.off()
