
R=/devel/github.com/linkeddata/rabel/rabel.js
C=python /devel/github.com/linkeddata/swap/cwm.py

# http://www.iana.org/assignments/link-relations/link-relations.xhtml#link-relations-1
#  http://www.iana.org/assignments/link-relations/link-relations.xml

relation.ttl : raw-relation.ttl infer.n3
		$C  raw-relation.ttl --think=infer.n3 > relation.ttl

#  Pick up a new XML file from IANA only if it has changed since our copy
link-relations.xml : ,gather
	curl --time-cond $@ --output $@ http://www.iana.org/assignments/link-relations/link-relations.xml


raw-relation.ttl : link-relations.xml $R
		node $R -format=application/xml -in=link-relations.xml -format=text/turtle -out=raw-relation.ttl


# we do not spray link relations, they are just a single file ontology.

# Spray data about anything in this director or a sister directory (people) or below
# into linked data files. THIS CREATES A LOT OF FILES!!
#
# link-relations.spray : relation.ttl $R
#		node $R -in=relation.ttl -spray=../ -help
