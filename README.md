# Structured data curriculum vitae

Produces my CV in various formats from a `bibtex` bibliography
database and a `yaml` file containing non-publication data, using
`pandoc` templates.

This is based on [Benjamin Schmidt's
CV-pandoc-healy](https://github.com/bmschmidt/CV-pandoc-healy). See
additional info there. It was then modified by [Richard Zach](https://github.com/rzach/cv-zach).

The resulting PDF can be viewed [here](http://phil.ucalgary.ca/profiles/215-28369/richard-zach-cv.pdf).

## Major changes to bschmidt's setup:

1. Obvs, it's my CV and not his; so there's different sections and organization.
1. Also generate CV in other formats (eg, MarkDown).
1. Bibliography is done using `biblatex`, using keywords instead of categories
   (see `rz-vita.sty`).
1. Bibliography includes links to [PhilPapers](https://philpapers.org/)
1. Bibliography also prints number of Google Scholar
   citations. `zach.bib` contains `scholar` fields that contains the
   Google Scholar cluster ID corresponding to an entry. The Makefile
   produces a file `cv-zach-scholar.tex` from this. It issues, for
   each entry that has citations, a command `\defscholar{<clusterid>}{<citations>}`.
   It is generated in the Makefile using a little script `citecounts`,
   which in turn uses [scholar.py](https://github.com/ckreibich/scholar.py) to query
   Google Scholar. `rz-vita.sty` loads that file and prints the
   citations.

## Major changes to rzach's setup:

1. Removed python dependency and use R instead to get both impact factors and citations
   - Need to install R with [scholar](https://github.com/jkeirstead/scholar) and [glue](https://github.com/tidyverse/glue) plugins
1. Now also added an I.F. field.

## Bib file requirements

1. The bib file has to have a `keyword` that matches existing publication types
1. You need to add a `scholar` field that is used to reference citations (see [Getting metadata from Google Scholar](#getting-metadata-from-google-scholar))
1. For

## Issues

1. Sometimes the `scholar` R package won't pull the correct publication and will instead get something random. Check super high-impact factors. There's a fairly crude filter on this right now, but I'm sure there's a more elegant solution for those that publish in the medical literature.

## Usage

- The citations and IFs are pulled manually not to anger Google using make `make cv-mikheyev-scholar.tex` before doing anything else.
- To compile the pdf run `make`
- To compile markdown run `make cv-mikheyev.md`

## Getting metadata from Google Scholar

To get find the Google Scholar cluster ID, click on the "cited by x"
link for the paper in Google Scholar. It'll take you to an URL like
```
https://scholar.google.com/scholar?oi=bibs&hl=en&cites=11913366570321310063
```
The cluster ID is the number after `cites=`. If Google Scholar has
more than one version for it, put all the cluster IDs in the `scholar`
field, separated by commas _but no spaces_.

To get the impact factor I use the `pubid` field from Google Scholar as a separate unique reference. I have no idea if it's possible to get it from the web page directly, but you can get it via the R `scholar` package using something like `pubs <- get_publications("d1Q6iL0AAAAJ")`

**Pro tip**: If you want to get started by downloading a quick and dirty bib file from Google with these fields pre-computed you can use the following code. Just keep in mind that this _will_ mess up a lot of things and you'll have to do a fair bit of manual editing of journal names, author lists, capitalization, etc. You'll need [bib2df](https://github.com/ropensci/bib2df) and `tidyverse` for this to work.

```{r}
mybib <- pubs %>% mutate(BIBTEXKEY = tolower(paste0(lastName(author), year, firstWord(title))),
              volume = gsub("(\\d+)\\s.*","\\1", number),
              pages = gsub(".*,\\s(.*)$","\\1", number),
              number =  gsub(".*\\((\\d+)\\).*","\\1", number),
              scholar = cid, ) %>% select(CATEGORY, BIBTEXKEY, title, author, journal, volume, number, pages, year, scholar, pubid)

df2bib(mybib, file = "mikheyev.bib")
```
