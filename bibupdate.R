# get bibliography from google scholar and print entried not present in the old bibliography with citekeys and pubids

# NOTE: change these as needed
bibfile <- "mikheyev.bib"
scholar_id <-"d1Q6iL0AAAAJ"

library(scholar)
library(tidyverse)
library(bib2df)
library(stringr)

lastName <- function(author)
  str_match(str_remove(tolower(author), "( jr)"), "\\w+ (\\w+)")[,2]

firstWord <- function(title)
  str_match(str_remove(tolower(title), "(the |an |and |a )"), "(\\w+)")[,2]

pubs <- get_publications(scholar_id) %>%
  mutate(key = paste0(lastName(author), year, firstWord(title)),
         volume = gsub("(\\d+)\\s.*","\\1", number),
         pages = gsub(".*,\\s(.*)$","\\1", number),
         number =  gsub(".*\\((\\d+)\\).*","\\1", number),
         scholar = cid, pubid ) %>%
  select(BIBTEXKEY = key, title, author, journal, volume, number, pages, year, scholar, pubid)

pubs$keywords = "article"
pubs$CATEGORY = "ARTICLE"

bib <- bib2df(bibfile) %>% filter(!is.na(SCHOLAR) & !is.na(PUBID)) %>% select(BIBTEXKEY, author = AUTHOR, title = TITLE, journal = JOURNAL, volume = VOLUME, pages = PAGES, year = YEAR, scholar = SCHOLAR, pubid = PUBID, keywords = KEYWORDS, thumbnail = THUMBNAIL)

pubs %>% filter(!BIBTEXKEY %in% bib$BIBTEXKEY & journal != "bioRxiv" & !is.na(journal)) %>%
  mutate(author = str_replace(author, "AS Mikheyev", "\\\\textbf{AS Mikheyev}")) %>% df2bib()


# This is a hack to get full author lists
#gsub("AS Mikheyev", "\\\textbf{AS Mikheyev}", gsub(",", " and", get_complete_authors(pubid = "tswL-GKFg8UC", id = scholar_id) ))



