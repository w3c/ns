#  The link rel=xxx  RDF properties. Convert XML definition file into RDF schema
#

SOURCE=https://www.iana.org/assignments/link-relations/link-relations.xml


linkRelations.ttl: link-relations-iana.xml /usr/local/bin/rabel
	/usr/local/bin/rabel -inXML=link-relations-iana.xml -out=link-relations.ttl

link-relations-iana.xml :
	curl $(SOURCE) > $@

update :
	curl $(SOURCE) > link-relations-iana.xml


/usr/local/bin/rabel :
    npm install -g rabel






