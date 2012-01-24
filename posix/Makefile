RDF = $(patsubst %.n3,%.rdf,$(wildcard *.n3))

all: $(RDF)

%.rdf: %.n3
	rapper -q -f writeBaseURI=0 -i turtle -o rdfxml-abbrev $< null:/ > $@
