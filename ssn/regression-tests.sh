#!/usr/bin/env bash
#
# Tests for the content negotiation of the ssn namespace URL. In
# general, a client that prefers HTML should get a redirect to the
# specification. Other clients get the Turtle or RDF/XML graph.
#
# Created: 14 December 2024
# Author: Bert Bos <bert@w3.org>
#
# Updated for the 2023 edition: the namespace now serves two editions.
# An ontology IRI serves the most recent edition that has it, a version
# IRI — .../ssn/2017/..., .../ssn/2023/... — serves that edition for
# good, and a term IRI no edition declares is a 404.
#
# Nine cases below expect something different from what they expected
# before, and each says so: an invented term used to be redirected to
# the specification with a made-up fragment, and is now a 404.
#
# Set BASE_URL to run against a server other than www.w3.org, and
# TEST_DELAY to something smaller than 0.5 when that server is local.

base="${BASE_URL:-https://www.w3.org/ns/ssn}"
delay="${TEST_DELAY:-0.5}"
spec2017='https://www.w3.org/TR/vocab-ssn/'
spec2023='https://www.w3.org/TR/vocab-ssn-2023/'

# A test has 6 parts:
#    0. name or number of the test
#    1. value of accept header
#    2. request (only the part after the $base URL)
#    3. expected response code
#    4. expected content type (only used if response = 200)
#    5. expected final URL (only used if response = 200)
#
tests=(
  # A browser, or anything that merely prefers HTML.
  0   'text/html,*/*;q=0.8'          ''             200  'text/html; charset=utf-8'  "$spec2023"
  1   'text/html,*/*;q=0.8'          '/'            200  'text/html; charset=utf-8'  "$spec2023"
  2   'text/html,*/*;q=0.8'          '/ssn'         404  '-'                         '-'   # CHANGED: no file of that name is served from the namespace IRI any more
  3   'text/html,*/*;q=0.8'          '/ssn.html'    200  'text/html; charset=utf-8'  "$spec2017"
  4   'text/html,*/*;q=0.8'          '/ssn.ttl'     200  'text/turtle'               "$base/2017/ssn.ttl"
  5   'text/html,*/*;q=0.8'          '/dul'         200  'text/turtle'               "$base/2017/dul"
  6   'text/html,*/*;q=0.8'          '/System'      200  'text/html; charset=utf-8'  "${spec2017}#SSNSystem"

  8   'text/html,*/*;q=0.8'          '/ssn?query'   404  '-'                         '-'   # CHANGED: as 2
  9   'text/html,*/*;q=0.8'          '/x?y'         404  '-'                         '-'   # CHANGED: an invented term is a 404
  10  'text/html,*/*;q=0.8'          '/x/y'         404  '-'                         '-'   # CHANGED: idem
  11  'text/html,*/*;q=0.8'          '/?foo'        200  'text/html; charset=utf-8'  "$spec2023"

  # A client that takes nothing but HTML.
  12  'text/html'                    ''             200  'text/html; charset=utf-8'  "$spec2023"
  13  'text/html'                    '/'            200  'text/html; charset=utf-8'  "$spec2023"
  14  'text/html'                    '/ssn'         404  '-'                         '-'   # CHANGED: as 2
  15  'text/html'                    '/ssn.html'    200  'text/html; charset=utf-8'  "$spec2017"
  16  'text/html'                    '/ssn.ttl'     200  'text/turtle'               "$base/2017/ssn.ttl"
  17  'text/html'                    '/dul'         406  '-'                         '-'
  18  'text/html'                    '/System'      200  'text/html; charset=utf-8'  "${spec2017}#SSNSystem"

  20  'text/html'                    '/ssn?query'   404  '-'                         '-'   # CHANGED: as 2
  21  'text/html'                    '/x?y'         404  '-'                         '-'   # CHANGED: an invented term is a 404
  22  'text/html'                    '/x/y'         404  '-'                         '-'   # CHANGED: idem
  23  'text/html'                    '/?foo'        200  'text/html; charset=utf-8'  "$spec2023"

  # A client with no preference at all.
  24  ''                             ''             200  'text/turtle'               "$base/2023/"
  25  ''                             '/'            200  'text/turtle'               "$base/2023/"
  26  ''                             '/ssn'         404  '-'                         '-'   # CHANGED: as 2
  27  ''                             '/ssn.html'    200  'text/html; charset=utf-8'  "$spec2017"
  28  ''                             '/ssn.ttl'     200  'text/turtle'               "$base/2017/ssn.ttl"
  29  ''                             '/dul'         200  'text/turtle'               "$base/2017/dul"
  30  ''                             '/System'      200  'text/turtle'               "$base/2023/dep/"

  32  ''                             '/ssn?query'   404  '-'                         '-'   # CHANGED: as 2
  33  ''                             '/x?y'         404  '-'                         '-'   # CHANGED: an invented term is a 404
  34  ''                             '/x/y'         404  '-'                         '-'   # CHANGED: idem
  35  ''                             '/?foo'        200  'text/turtle'               "$base/2023/"
  36  'text/html,text/turtle'        '/'            200  'text/turtle'               "$base/2023/"
  37  'application/rdf+xml'          '/'            200  'application/rdf+xml'       "$base/2023/"
  38  'text/turtle'                  '/hosts'       404  '-'                         '-'   # CHANGED: sosa:hosts is not a term of this namespace
  39  '*/*'                          '/'            200  'text/turtle'               "$base/2023/"
  40  'text/html,*/*;qs=0.8'         '/x?term=y'    404  '-'                         '-'
  41  'text/turtle,text/html;qs=0.1' '/'            200  'text/turtle'               "$base/2023/"

  # The version IRI of each edition, which never moves.
  50  ''                             '/2017/'       200  'text/turtle'               "$base/2017/"
  51  'text/html'                    '/2017/'       200  'text/html; charset=utf-8'  "$spec2017"
  52  ''                             '/2023/'       200  'text/turtle'               "$base/2023/"
  53  'text/html'                    '/2023/'       200  'text/html; charset=utf-8'  "$spec2023"
  54  'application/rdf+xml'          '/2017/'       200  'application/rdf+xml'       "$base/2017/"
  55  ''                             '/2017/dul'    200  'text/turtle'               "$base/2017/dul"
  56  ''                             '/2017/ext'    200  'text/turtle'               "$base/2017/ext"
  57  ''                             '/2017/systems/' 200 'text/turtle'              "$base/2017/systems/"
  58  ''                             '/2023/oms/'   200  'text/turtle'               "$base/2023/oms/"

  # A module IRI serves the most recent edition that has it.  The System
  # capabilities module and the DUL alignment moved to the sosa namespace in
  # 2023, so theirs is still the 2017 edition here.
  60  ''                             '/systems/'    200  'text/turtle'               "$base/2017/systems/"
  61  ''                             '/ext'         200  'text/turtle'               "$base/2017/ext"
  62  ''                             '/oms/'        200  'text/turtle'               "$base/2023/oms/"
  63  'text/html'                    '/systems/'    200  'text/html; charset=utf-8'  "$spec2017"

  # A term IRI serves the most recent edition that declares the term.
  70  'text/html'                    '/systems/Accuracy'  200 'text/html; charset=utf-8' "${spec2017}#SSNSYSTEMAccuracy"
  71  ''                             '/systems/Accuracy'  200 'text/turtle'         "$base/2017/systems/"
  72  'text/html'                    '/hasProperty'       200 'text/html; charset=utf-8' "${spec2017}#SSNhasProperty"
  73  ''                             '/hasProperty'       200 'text/turtle'         "$base/2023/dep/"

  # An IRI no edition declares is a 404, whatever the client asks for.
  80  'text/html'                    '/Licorne'     404  '-'                         '-'
  81  ''                             '/Licorne'     404  '-'                         '-'
  82  ''                             '/systems/Licorne' 404 '-'                      '-'
  83  ''                             '/2023/Licorne' 404 '-'                         '-'

  # The files this namespace used to serve are the files of 2017.
  90  ''                             '/dul.ttl'     200  'text/turtle'               "$base/2017/dul.ttl"
  91  ''                             '/systems/ssn-system.ttl' 200 'text/turtle'     "$base/2017/systems/ssn-system.ttl"
  92  ''                             '/ssn.rdf'     200  'application/rdf+xml'       "$base/2017/ssn.rdf"
)

for ((i = 0; 6 * i < ${#tests[@]}; i++)); do
  n=${tests[$((6*i+0))]}
  h=${tests[$((6*i+1))]}
  f=${tests[$((6*i+2))]}
  echo -e "$n \c"
  r=$(curl ${h:+-H "Accept: $h"} -s --head -L -o /dev/null \
           -w '%{response_code}\t%{content_type}\t%{url_effective}\n' \
           $base$f) || echo "curl failed"
  response=$(cut -f1 <<<"$r")
  type=$(cut -f2 <<<"$r")
  url=$(cut -f3 <<<"$r")
  if [[ ${tests[$((6*i+3))]} != $response ]]; then
    echo "FAIL (response code = $response)"
  elif [[ $response == 200 ]] && [[ ${tests[$((6*i+4))]} != "$type" ]]; then
    echo "FAIL (content type = $type)"
  elif [[ $response == 200 ]] && [[ ${tests[$((6*i+5))]} != "$url" ]]; then
    echo "FAIL (url = $url)"
  else
    echo -e "\r\c"
  fi
  sleep $delay			# W3C's Cloudflare frontend has very low limits
done
echo
