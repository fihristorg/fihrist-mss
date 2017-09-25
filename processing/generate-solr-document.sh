#!/usr/bin/env bash

# Command arguments
# $1 = xQuery file
# $2 = Output file
# $3 = Solr `type` (for deleting only one type of record)
# $4 = Solr address for indexing

echo "Generating Solr XML document"
java -cp "saxon/saxon9he.jar" net.sf.saxon.Query -q:$1 | xmllint --format - > $2

echo "Emptying Solr"
curl "http://${4}:8983/solr/fihrist-mss/update?stream.body=<delete><query>type:${3}</query></delete>&commit=true"

echo "Indexing in Solr"
curl "http://${4}:8983/solr/fihrist-mss/update?commit=true" --data-binary @$2 -H "Content-Type: text/xml"