#
W=../..
S=$W/2000/10/swap
C=python $S/cwm.py

.SUFFIXES: .ttl .rdf .n3 .ldif

.n3.rdf:
		python $S/cwm.py --n3 $< --rdf --quiet > $@
.n3.ttl:
			python $S/cwm.py --n3 $<  --quiet > $@

,some : acl.rdf acl.ttl
			echo


#ends
