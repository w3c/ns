#
W=../..
S=$W/2000/10/swap
C=python $S/cwm.py

.SUFFIXES: .rdf .n3 .ldif

.n3.rdf:
	python $S/cwm.py --quiet --n3 $< --rdf --quiet > $@



#ends