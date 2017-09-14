
R=/devel/github.com/linkeddata/rabel/rabel.js

# http://www.iana.org/assignments/link-relations/link-relations.xhtml#link-relations-1
#  http://www.iana.org/assignments/link-relations/link-relations.xml


#  Pick up a new XML file from IANA only if it has changed since our copy
link-relations.xml : ,gather
	curl --time-cond $@ --output $@ http://www.iana.org/assignments/link-relations/link-relations.xml


link-relations.ttl : link-relations.xml $R
		node $R -format=application/xml -in=link-relations.xml -format=text/turtle -out=link-relations.ttl

# we do not spray link relations, they are just a single file ontology.

# Spray data about anything in this director or a sister directory (people) or below
# into linked data files. THIS CREATES A LOT OF FILES!!
#
# link-relations.spray : link-relations.ttl $R
#		node $R -in=link-relations.ttl -spray=../ -help
