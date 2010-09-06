#
W=..
S=$W/2000/10/swap
C=python $S/cwm.py

.SUFFIXES: .rdf .n3 .ldif

.n3.rdf:
	python $S/cwm.py --n3 $< --rdf --quiet > $@


trip.rdf: trip.n3
	$C --quiet trip.n3 --rdf > trip.rdf 

#ends