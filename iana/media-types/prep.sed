
s?<file type="template">\(.*\)</file>?<class rdf:resource="http://www.w3.org/ns/iana/media-types/\1#Resource"/>?

s?><xref type="uri" data="\(.*\)"/>? rdf:resource="http://www.w3.org/ns/iana/media-types/\1">?


s?<xref type="rfc" data="rfc\([0-9]*\)"/>?<xref rdf:resource="https://tools.ietf.org/html/rfc\1"/>?g

# EG   <xref type="rfc" data="rfc5874"/>
# ->   https://tools.ietf.org/html/rfc5109
