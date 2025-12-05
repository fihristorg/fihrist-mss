#!/usr/bin/env bash

if [[ ! "`pwd`" == *-mss/processing ]]; then
    echo "This script must be run from the processing folder"
    exit 1;
fi

LOGFILE="update-authority-files.log"

TEMPFILE1=$(mktemp)
TEMPFILE2=$(mktemp)
TEMPFILE3=$(mktemp)
TEMPFILE4=$(mktemp)

AUTHORITYDIR="../authority"

echo "Updating files in authority folder using on $(date +"%Y-%m-%d %H:%M:%S") with new works/persons/subjects/places added to TEI files in the collections folder." > $LOGFILE

java -Xmx1G -cp "saxon/saxon9he.jar" net.sf.saxon.Query -q:update-works-authority-file.xquery -o:"$TEMPFILE1" 2>> $LOGFILE
if [ $? -gt 0 ]; then
    echo "XQuery failed while trying to update the works authority. Updating of authority files cancelled. Please raise an issue on GitHub, attaching $LOGFILE"
    exit 1;
else
    cp "$TEMPFILE1" "$AUTHORITYDIR/works_additions.xml" 2>> $LOGFILE
    if [ $? -gt 0 ]; then
        echo "Cannot write to authority folder. Check permissions on $AUTHORITYDIR and re-run."
        exit 1;
    fi
fi

java -Xmx1G -cp "saxon/saxon9he.jar" net.sf.saxon.Query -q:update-persons-authority-file.xquery -o:"$TEMPFILE2" 2>> $LOGFILE
if [ $? -gt 0 ]; then
    echo "XQuery failed while trying to update the persons authority. Updating of authority files cancelled. Please raise an issue on GitHub, attaching $LOGFILE"
    exit 1;
else
    cp "$TEMPFILE2" "$AUTHORITYDIR/persons_additions.xml" 2>> $LOGFILE
    if [ $? -gt 0 ]; then
        echo "Cannot write to authority folder. Check permissions on $AUTHORITYDIR and re-run."
        exit 1;
    fi
fi

java -Xmx1G -cp "saxon/saxon9he.jar" net.sf.saxon.Query -q:update-subjects-authority-file.xquery -o:"$TEMPFILE3" 2>> $LOGFILE
if [ $? -gt 0 ]; then
    echo "XQuery failed while trying to update the subjects authority. Updating of authority files cancelled. Please raise an issue on GitHub, attaching $LOGFILE"
    exit 1;
else
    cp "$TEMPFILE3" "$AUTHORITYDIR/subjects_additions.xml" 2>> $LOGFILE
    if [ $? -gt 0 ]; then
        echo "Cannot write to authority folder. Check permissions on $AUTHORITYDIR and re-run."
        exit 1;
    fi
fi

java -Xmx1G -cp "saxon/saxon9he.jar" net.sf.saxon.Query -q:update-places-authority-file.xquery -o:"$TEMPFILE4" 2>> $LOGFILE
if [ $? -gt 0 ]; then
    echo "XQuery failed while trying to update the places authority. Updating of authority files cancelled. Please raise an issue on GitHub, attaching $LOGFILE"
    exit 1;
else
    cp "$TEMPFILE4" "$AUTHORITYDIR/places_additions.xml" 2>> $LOGFILE
    if [ $? -gt 0 ]; then
        echo "Cannot write to authority folder. Check permissions on $AUTHORITYDIR and re-run."
        exit 1;
    else
        echo "All authority files updated. Check for changes in your Git client. If any, commit and push them. Then re-index to update the web site."
        exit 0;
    fi
fi

