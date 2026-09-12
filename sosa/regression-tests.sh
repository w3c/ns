#!/usr/bin/env bash
#
# Tests for the content negotiation of the sosa namespace URL. In
# general, a client that prefers HTML should get a redirect to the
# specification. Other clients get the Turtle or RDF/XML graph.
#
# Created: 14 December 2024
# Author: Bert Bos <bert@w3.org>
#
# Updated for the 2023 edition: the namespace now serves two editions.
# An ontology IRI serves the most recent edition that has it, a version
# IRI — .../sosa/2017/..., .../sosa/2023/... — serves that edition for
# good, and a term IRI no edition declares is a 404.
#
# Eight cases below expect something different from what they expected
# before, and each says so: an invented term used to be redirected to
# the specification with a made-up fragment, and is now a 404.
#
# Set BASE_URL to run against a server other than www.w3.org, and
# TEST_DELAY to something smaller than 0.5 when that server is local.

base="${BASE_URL:-https://www.w3.org/ns/sosa}"
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
  2   'text/html,*/*;q=0.8'          '/sosa'        404  '-'                         '-'   # CHANGED: no file of that name is served from the namespace IRI any more
  3   'text/html,*/*;q=0.8'          '/sosa.html'   200  'text/html; charset=utf-8'  "$spec2017"
  4   'text/html,*/*;q=0.8'          '/sosa.ttl'    200  'text/turtle'               "$base/2017/sosa.ttl"
  5   'text/html,*/*;q=0.8'          '/om'          200  'text/turtle'               "$base/2017/om"
  6   'text/html,*/*;q=0.8'          '/Actuation'   200  'text/html; charset=utf-8'  "${spec2023}#SOSAActuation"

  8   'text/html,*/*;q=0.8'          '/sosa?query'  404  '-'                         '-'   # CHANGED: as 2
  9   'text/html,*/*;q=0.8'          '/x?y'         404  '-'                         '-'   # CHANGED: an invented term is a 404
  10  'text/html,*/*;q=0.8'          '/x/y'         404  '-'                         '-'   # CHANGED: idem
  11  'text/html,*/*;q=0.8'          '/?foo'        200  'text/html; charset=utf-8'  "$spec2023"

  # A client that takes nothing but HTML.
  12  'text/html'                    ''             200  'text/html; charset=utf-8'  "$spec2023"
  13  'text/html'                    '/'            200  'text/html; charset=utf-8'  "$spec2023"
  14  'text/html'                    '/sosa'        404  '-'                         '-'   # CHANGED: as 2
  15  'text/html'                    '/sosa.html'   200  'text/html; charset=utf-8'  "$spec2017"
  16  'text/html'                    '/sosa.ttl'    200  'text/turtle'               "$base/2017/sosa.ttl"
  17  'text/html'                    '/om'          406  '-'                         '-'
  18  'text/html'                    '/Actuation'   200  'text/html; charset=utf-8'  "${spec2023}#SOSAActuation"

  20  'text/html'                    '/sosa?query'  404  '-'                         '-'   # CHANGED: as 2
  21  'text/html'                    '/x?y'         404  '-'                         '-'   # CHANGED: an invented term is a 404
  22  'text/html'                    '/x/y'         404  '-'                         '-'   # CHANGED: idem
  23  'text/html'                    '/?foo'        200  'text/html; charset=utf-8'  "$spec2023"

  # A client with no preference at all.
  24  ''                             ''             200  'text/turtle'               "$base/2023/"
  25  ''                             '/'            200  'text/turtle'               "$base/2023/"
  26  ''                             '/sosa'        404  '-'                         '-'   # CHANGED: as 2
  27  ''                             '/sosa.html'   200  'text/html; charset=utf-8'  "$spec2017"
  28  ''                             '/sosa.ttl'    200  'text/turtle'               "$base/2017/sosa.ttl"
  29  ''                             '/om'          200  'text/turtle'               "$base/2017/om"
  30  ''                             '/Actuation'   200  'text/turtle'               "$base/2023/act/"
  31  ''                             '/prov'        200  'text/turtle'               "$base/2023/prov"
  32  ''                             '/sosa?query'  404  '-'                         '-'   # CHANGED: as 2
  33  ''                             '/x?y'         404  '-'                         '-'   # CHANGED: an invented term is a 404
  34  ''                             '/x/y'         404  '-'                         '-'   # CHANGED: idem
  35  ''                             '/?foo'        200  'text/turtle'               "$base/2023/"

  36  'text/html,text/turtle'        '/'            200  'text/turtle'               "$base/2023/"
  37  'application/rdf+xml'          '/'            200  'application/rdf+xml'       "$base/2023/"
  38  'text/turtle'                  '/hosts'       200  'text/turtle'               "$base/2023/common/"
  39  '*/*'                          '/'            200  'text/turtle'               "$base/2023/"
  40  'text/html,*/*;qs=0.8'         '/x?term=y'    404  '-'                         '-'
  41  'text/turtle,text/html;qs=0.1' '/'            200  'text/turtle'               "$base/2023/"

  # The version IRI of each edition, which never moves.
  50  ''                             '/2017/'       200  'text/turtle'               "$base/2017/"
  51  'text/html'                    '/2017/'       200  'text/html; charset=utf-8'  "$spec2017"
  52  ''                             '/2023/'       200  'text/turtle'               "$base/2023/"
  53  'text/html'                    '/2023/'       200  'text/html; charset=utf-8'  "$spec2023"
  54  'application/rdf+xml'          '/2017/'       200  'application/rdf+xml'       "$base/2017/"
  55  ''                             '/2017/om'     200  'text/turtle'               "$base/2017/om"
  56  ''                             '/2017/prov'   200  'text/turtle'               "$base/2017/prov"
  57  ''                             '/2023/prov'   200  'text/turtle'               "$base/2023/prov"
  58  ''                             '/2023/act/'   200  'text/turtle'               "$base/2023/act/"
  59  ''                             '/2017/sampling/' 200 'text/turtle'             "$base/2017/sampling/"

  # A module IRI serves the most recent edition that has it.
  60  ''                             '/sampling/'   200  'text/turtle'               "$base/2023/sampling/"
  61  ''                             '/systems/'    200  'text/turtle'               "$base/2023/systems/"
  62  ''                             '/oms/'        200  'text/turtle'               "$base/2023/oms/"
  63  ''                             '/oboe'        200  'text/turtle'               "$base/2023/oboe"
  64  ''                             '/dul'         200  'text/turtle'               "$base/2023/dul"
  65  ''                             '/act/'        200  'text/turtle'               "$base/2023/act/"
  66  ''                             '/system-capability-properties' 200 'text/turtle' "$base/2023/system-capability-properties"
  67  'text/html'                    '/sampling/'   200  'text/html; charset=utf-8'  "$spec2023"

  # A term IRI serves the most recent edition that declares the term.
  70  'text/html'                    '/Sensor'      200  'text/html; charset=utf-8'  "${spec2023}#SOSASensor"
  71  ''                             '/Sensor'      200  'text/turtle'               "$base/2023/obs/"
  72  'text/html'                    '/sampling/relatedSample' 200 'text/html; charset=utf-8' "${spec2023}#SAMRrelatedSample"
  73  ''                             '/sampling/relatedSample' 200 'text/turtle'      "$base/2023/sampling/"
  74  'text/html'                    '/oms/relatedSampling'   200 'text/html; charset=utf-8' "${spec2023}#OMSrelatedSampling"
  75  ''                             '/oms/relatedSampling'   200 'text/turtle'      "$base/2023/oms/"
  # A term the 2023 edition dropped keeps its 2017 definition.
  76  'text/html'                    '/hasSampledFeature'     200 'text/html; charset=utf-8' "${spec2017}#SOSAhasSampledFeature"
  # sosa:hasSampledFeature was declared by the SSN extensions module, so its
  # graph is the one of that module, in the namespace next door.
  77  ''                             '/hasSampledFeature'     200 'text/turtle'      "${SSN_BASE:-https://www.w3.org/ns/ssn}/2017/ext"
  # A term the 2023 edition deprecated has no anchor there: the reader goes
  # to the last edition that does define it, the graph to the 2023 module.
  78  'text/html'                    '/ObservableProperty'    200 'text/html; charset=utf-8' "${spec2017}#SOSAObservableProperty"
  79  ''                             '/ObservableProperty'    200 'text/turtle'      "$base/2023/dep/"

  # An IRI no edition declares is a 404, whatever the client asks for.
  80  'text/html'                    '/Licorne'     404  '-'                         '-'
  81  ''                             '/Licorne'     404  '-'                         '-'
  82  ''                             '/sampling/Licorne' 404 '-'                     '-'
  83  ''                             '/2023/Licorne' 404 '-'                         '-'
  84  ''                             '/nosuchfile.ttl' 404 '-'                       '-'

  # The files this namespace used to serve are the files of 2017.
  90  ''                             '/om.ttl'      200  'text/turtle'               "$base/2017/om.ttl"
  91  ''                             '/oboe.ttl'    200  'text/turtle'               "$base/2017/oboe.ttl"
  92  ''                             '/sampling/sosa-sampling.ttl' 200 'text/turtle' "$base/2017/sampling/sosa-sampling.ttl"
  93  ''                             '/sosa.rdf'    200  'application/rdf+xml'       "$base/2017/sosa.rdf"
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
