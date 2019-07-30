library(scholar)
library(glue)
pubs <- get_publications("d1Q6iL0AAAAJ")
for (i in 1:nrow(pubs)) {
  cites <- pubs[i, "cites"]
  cid <- pubs[i, "cid"]
  if (cites > 0)
    print(glue('\\defscholar{{{cid}}}{{{cites}}}'))
}
