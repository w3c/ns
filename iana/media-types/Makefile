### Media types

# touch ,gather to trigger:
#   picking up of the XML file from IANA only if if changed there since our copy.
R=/devel/github.com/linkeddata/rabel/rabel.js

media-types.xml: ,gather
	curl  --time-cond $@ --output $@ http://www.iana.org/assignments/media-types/media-types.xml

#media-types.rdf : media-types.xml xml2rdf.sed prep.sed
#	sed -f prep.sed < $< > ,temp-media-types.xml
#	sed -f xml2rdf.sed < ,temp-media-types.xml > $@
#
#old-media-types.ttl : media-types.rdf
#		rabel -format=application/rdf+xml -in=media-types.rdf -format=text/turtle -out=old-media-types.ttl

media-types.ttl : media-types.xml $R
		node $R -format=application/xml -in=media-types.xml -format=text/turtle -out=media-types.ttl

# Spray data about anything in this director or a sister directory (people) or below
# into linked data files. THIS CREATES A LOT OF FILES!!

media-types.spray : media-types.ttl $R
		node $R -in=media-types.ttl -spray=../ -help

#test-media-types.ttl : test-media-types.xml $R
#	node $R -format=application/xml -in=test-media-types.xml -format=text/turtle -out=test-media-types.ttl
#
#	test-media-types.spray : test-media-types.ttl $R
#		node $R -in=test-media-types.ttl -spray=../ -help
