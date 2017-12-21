#!/usr/bin/env bash

# Command arguments
# $1 = Optional mode:
#           Append 'force' to disable checking for data issues and push to Solr without prompting
#           Append 'noindex' to generate the files and do the checking but not push to Solr

if [ ! "$1" == "force" ]; then
    # Give up if any one index fails or is abandoned
    set -e
fi

cd "${0%/*}"

# Re-index manuscripts (includes rebuilding customized manuscript HTML pages, which must be run first)
./generate-html.sh && ./generate-solr-document.sh manuscripts.xquery mss_index.xml manuscript solr01-qa.bodleian.ox.ac.uk $1

# Reindex people
./generate-solr-document.sh people.xquery people_index.xml person solr01-qa.bodleian.ox.ac.uk $1

# Reindex works
./generate-solr-document.sh works.xquery works_index.xml work solr01-qa.bodleian.ox.ac.uk $1

# Fourth index not yet specified
#./generate-solr-document.sh ????.xquery ????_index.xml ???? solr01-qa.bodleian.ox.ac.uk $1
