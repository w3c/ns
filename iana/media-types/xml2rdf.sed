3d
2d
1s:<?xml version='1.0' encoding='UTF-8'?>:<rdf\:RDF xmlns="http\://www.w3.org/ns/iana/vocab#" xmlns\:a="http\://www.w3.org/ns/iana/vocab#" xmlns\:rdf="http\://www.w3.org/1999/02/22-rdf-syntax-ns#">:

$a\
</rdf:RDF>
s/ \([a-z]*\)=/ a:\1=/g
s/a:xmlns=/xmlns=/

# Fix XML NS which doesn't work with RDF, must end in # or /
s?xmlns="http://www.iana.org/assignments"?xmlns="http://www.iana.org/assignments#"?

# ends
