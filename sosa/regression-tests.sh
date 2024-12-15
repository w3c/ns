#!/usr/bin/env bash
#
# Tests for the content negotiation of the sosa namespace URL. In
# general, a client that prefers HTML should get a redirect to the
# specification. Other clients get the sosa.ttl or sosa.rdf files.
#
# Created: 14 December 2024
# Author: Bert Bos <bert@w3.org>

base="https://www.w3.org/ns/sosa"
base="http://localhost/~bert/ns/sosa"

# A test has 6 parts:
#    0. name or number of the test
#    1. value of accept header
#    2. request (only the part after the $base URL)
#    3. expected response code
#    4. expected content type (only used if response = 200)
#    5. expected final URL (only used if response = 200)
#
tests=(
  0   'text/html,*/*;q=0.8'          ''             200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  1   'text/html,*/*;q=0.8'          '/'            200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  2   'text/html,*/*;q=0.8'          '/sosa'        200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  3   'text/html,*/*;q=0.8'          '/sosa.html'   200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  4   'text/html,*/*;q=0.8'          '/sosa.ttl'    200  'text/turtle'               "$base/sosa.ttl"
  5   'text/html,*/*;q=0.8'          '/om'          200  'text/turtle'               "$base/om"
  6   'text/html,*/*;q=0.8'          '/Actuation'   200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/#SOSAActuation'

  8   'text/html,*/*;q=0.8'          '/sosa?query'  200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  9   'text/html,*/*;q=0.8'          '/x?y'         200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/#SOSAx'
  10  'text/html,*/*;q=0.8'          '/x/y'         200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/#SOSAx/y'
  11  'text/html,*/*;q=0.8'          '/?foo'        200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  12  'text/html'                    ''             200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  13  'text/html'                    '/'            200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  14  'text/html'                    '/sosa'        200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  15  'text/html'                    '/sosa.html'   200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  16  'text/html'                    '/sosa.ttl'    200  'text/turtle'               "$base/sosa.ttl"
  17  'text/html'                    '/om'          406  '-'                         '-'
  18  'text/html'                    '/Actuation'   200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/#SOSAActuation'

  20  'text/html'                    '/sosa?query'  200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  21  'text/html'                    '/x?y'         200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/#SOSAx'
  22  'text/html'                    '/x/y'         200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/#SOSAx/y'
  23  'text/html'                    '/?foo'        200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  24  ''                             ''             200  'text/turtle'               "$base/"
  25  ''                             '/'            200  'text/turtle'               "$base/"
  26  ''                             '/sosa'        200  'text/turtle'               "$base/sosa"
  27  ''                             '/sosa.html'   200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  28  ''                             '/sosa.ttl'    200  'text/turtle'               "$base/sosa.ttl"
  29  ''                             '/om'          200  'text/turtle'               "$base/om"
  30  ''                             '/Actuation'   200  'text/turtle'               "$base/Actuation"
  31  ''                             '/prov'        200  'text/turtle'               "$base/prov/"
  32  ''                             '/sosa?query'  200  'text/turtle'               "$base/sosa?query"
  33  ''                             '/x?y'         200  'text/turtle'               "$base/x?y"
  34  ''                             '/x/y'         200  'text/turtle'               "$base/x/y"
  35  ''                             '/?foo'        200  'text/turtle'               "$base/?foo"
  36  'text/html,text/turtle'        '/'            200  'text/turtle'               "$base/"
  37  'application/rdf+xml'          '/'            200  'application/rdf+xml'       "$base/"
  38  'text/turtle'                  '/hosts'       200  'text/turtle'               "$base/hosts"
  39  '*/*'                          '/'            200  'text/turtle'               "$base/"
  40  'text/html,*/*;qs=0.8'         '/x?term=y'    404  '-'                         '-'
  41  'text/turtle,text/html;qs=0.1' '/'            200  'text/turtle'               "$base/"
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
done
echo
