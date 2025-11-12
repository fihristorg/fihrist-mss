#!/usr/bin/env bash


java -Xmx1G -cp "saxon/saxon9he.jar" net.sf.saxon.Query -q:deleted-identifiers.xquery -o:deleted_ids_mapping.rb