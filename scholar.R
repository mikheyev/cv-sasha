library(scholar)
library(glue)
pubs <- get_publications("d1Q6iL0AAAAJ")
# citations
for (i in 1:nrow(pubs)) {
  cites <- pubs[i, "cites"]
  cid <- pubs[i, "cid"]
  pid <- pubs[i, "pubid"]
  journalIF <- round(get_impactfactor(pubs[i, "journal"])$ImpactFactor, 1)
  if (cites > 0)
    print(glue('\\defscholar{{{cid}}}{{{cites}}}'))
  if (! is.na(journalIF) & journalIF < 70)  # sometimes you don't find the journal and get a medical one
    print(glue('\\defscholarIF{{{pid}}}{{{journalIF}}}'))
}
