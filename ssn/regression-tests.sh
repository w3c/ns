#!/usr/bin/env bash
#
# Tests for the content negotiation of the ssn namespace URL. In
# general, a client that prefers HTML should get a redirect to the
# specification. Other clients get the ssn.ttl or ssn.rdf files.
#
# Created: 14 December 2024
# Author: Bert Bos <bert@w3.org>

base="https://www.w3.org/ns/ssn"

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
  2   'text/html,*/*;q=0.8'          '/ssn'         200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  3   'text/html,*/*;q=0.8'          '/ssn.html'    200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  4   'text/html,*/*;q=0.8'          '/ssn.ttl'     200  'text/turtle'               "$base/ssn.ttl"
  5   'text/html,*/*;q=0.8'          '/dul'         200  'text/turtle'               "$base/dul"
  6   'text/html,*/*;q=0.8'          '/System'      200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/#SSNSystem'

  8   'text/html,*/*;q=0.8'          '/ssn?query'   200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  9   'text/html,*/*;q=0.8'          '/x?y'         200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/#SSNx'
  10  'text/html,*/*;q=0.8'          '/x/y'         200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/#SSNx/y'
  11  'text/html,*/*;q=0.8'          '/?foo'        200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  12  'text/html'                    ''             200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  13  'text/html'                    '/'            200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  14  'text/html'                    '/ssn'         200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  15  'text/html'                    '/ssn.html'    200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  16  'text/html'                    '/ssn.ttl'     200  'text/turtle'               "$base/ssn.ttl"
  17  'text/html'                    '/dul'         406  '-'                         '-'
  18  'text/html'                    '/System'      200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/#SSNSystem'

  20  'text/html'                    '/ssn?query'   200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  21  'text/html'                    '/x?y'         200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/#SSNx'
  22  'text/html'                    '/x/y'         200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/#SSNx/y'
  23  'text/html'                    '/?foo'        200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  24  ''                             ''             200  'text/turtle'               "$base/"
  25  ''                             '/'            200  'text/turtle'               "$base/"
  26  ''                             '/ssn'         200  'text/turtle'               "$base/ssn"
  27  ''                             '/ssn.html'    200  'text/html; charset=utf-8'  'https://www.w3.org/TR/vocab-ssn/'
  28  ''                             '/ssn.ttl'     200  'text/turtle'               "$base/ssn.ttl"
  29  ''                             '/dul'         200  'text/turtle'               "$base/dul"
  30  ''                             '/System'      200  'text/turtle'               "$base/System"

  32  ''                             '/ssn?query'   200  'text/turtle'               "$base/ssn?query"
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
