### Media types

R ?= /devel/github.com/linkeddata/rabel/rabel.js

PHONY=all
all: media-types.spray

# touch ,gather to trigger:
#   picking up of the XML file from IANA only if changed there since our copy.
media-types.xml: ,gather
	curl  --time-cond $@ --output $@ http://www.iana.org/assignments/media-types/media-types.xml

#media-types.rdf : media-types.xml xml2rdf.sed prep.sed
#	sed -f prep.sed < $< > ,temp-media-types.xml
#	sed -f xml2rdf.sed < ,temp-media-types.xml > $@
#
#old-media-types.ttl : media-types.rdf
#		rabel -format=application/rdf+xml -in=media-types.rdf -format=text/turtle -out=old-media-types.ttl

media-types.ttl : check-tools media-types.xml $R
		$R -format=application/xml -in=media-types.xml -format=text/turtle -out=media-types.ttl

# Spray data about anything in this director or a sister directory (people) or below
# into linked data files. THIS CREATES A LOT OF FILES!!

media-types.spray : check-tools media-types.ttl $R
		mkdir -p application audio font haptics image message model multipart text video ../person
		$R -in=media-types.ttl -spray=../ -help

#test-media-types.ttl : test-media-types.xml $R
#	$R -format=application/xml -in=test-media-types.xml -format=text/turtle -out=test-media-types.ttl
#
#	test-media-types.spray : test-media-types.ttl $R
#		$R -in=test-media-types.ttl -spray=../ -help


@PHONY:check-tools
check-tools:
	@ [ -x "$R" ] || (echo "\nSet env variable R with path to rabel.js\n"; false)
