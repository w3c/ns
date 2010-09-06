#
W=../..
S=$W/2000/10/swap
C=python $S/cwm.py

.SUFFIXES: .rdf .n3 .ldif

.n3.rdf:
	python $S/cwm.py --n3 $< --rdf --quiet > $@


,all : ldif.rdf xml.rdf o2.rdf unit.rdf link.rdf
	touch ,all
ldif.rdf: ldif.n3
	$C --quiet ldif.n3 --rdf > ldif.rdf 

xml.rdf: xml.n3
	$C --quiet xml.n3 --rdf > xml.rdf 

#ends