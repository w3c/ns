#!/bin/sh

root=activitystreams
mkdir -p $root-history
suffix=.jsonld
file=$root$suffix
tags=`cvs log $file | grep '^revision' | cut -b 10-`

cat <<EOF > $root-history/Overview.html
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html
  PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xht
ml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en"><head><title>Document Version History</title></head><body>
EOF

for tag in $tags; do
  out=$root-history/v$tag$suffix
  echo checking out $out
  cvs -Q update -p -r $tag $file > $out
  hash=sha256hex-`sha256sum $out | cut -c1-64`
  cp -a "$out" "$root-history/$hash$suffix"
  old=$tag
  
  echo "<p><a href=\"v$old$suffix\">v$old$suffix</a> or <a href=\"$hash$suffix\">$hash$suffix</a></p>" >> $root-history/Overview.html  
done

cat <<EOF >> "$root-history/Overview.html"
</body></html>
EOF

