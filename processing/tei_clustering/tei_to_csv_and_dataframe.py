from bs4 import BeautifulSoup as bs
import glob
import csv
import argparse
import pandas as pd
from geopy.geocoders import Nominatim
import json

def date_to_century (date):

    century=date[:2]
    century=int(century)
    century=century+1

    return century

def origplace_to_country (origplace):
    #TODO - this is a hack - remove!
    if origplace=="Greater Iran":
        origplace="Iran"
    
    location = geolocator.geocode(origplace, addressdetails=True)
    country=""
    if location:

        country=location.raw['address']['country_code']
    return country


geolocator = Nominatim(user_agent="tei_to_csv")


# construct the argument parse and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-t", "--teipath", required=True, help="Path to tei")
args = vars(ap.parse_args())

teipath=args["teipath"]

#opens csv file for output
csvfile = open('output.csv', 'w', newline='')
csvwriter = csv.writer(csvfile, delimiter=',',quotechar='"', quoting=csv.QUOTE_MINIMAL)

csvwriter.writerow(
    ["msid", "filename", "repository", "collection", "idno", "start_century", "end_century", "origplace", "country", "material", "script", "mainlang",
     "decorated", "orientation", "lines", "size"])

corpus = glob.glob(teipath+'/*.xml')

#loop through xml files
for file in corpus:
    
    with open(file, 'r') as xml:
        
        soup=bs(xml, 'lxml')
        #print(soup)
        print (file)

        filename=file.rpartition("/")[-1]

        msid = ""
        try:
            msid = soup.find("tei")["xml:id"]

        except:
            msid=""
        print (msid)

        repository=""
        try:
            repository=soup.find("msidentifier").find("repository")
            repository=repository.get_text()
        except:
            repository=""
        print (repository)

        collection = ""
        try:
            collection = soup.find("msidentifier").find("collection")
            collection = collection.get_text()
        except:
            collection = ""
        print(collection)

        idno=""
        try:
            idno = soup.find("msidentifier").find("idno")
            idno = idno.get_text()
        except:
            idno=""
        print(idno)

        origdate = ""
        try:
            origdate = soup.find("history").find("origdate")
            origdate = origdate.get_text()
        except:
            origdate = ""
        print(origdate)

        start_century = ""
        try:
            start_century = soup.find("origdate")["when"]
        except:
            try:
                start_century = soup.find("origdate")["from"]
            except:
                try:
                    start_century = soup.find("origdate")["notbefore"]
                except:
                    start_century = ""

        if start_century:
            start_century = date_to_century(start_century)
        print(start_century)

        end_century = ""
        try:
            end_century = soup.find("origdate")["when"]
        except:
            try:
                end_century = soup.find("origdate")["to"]
            except:
                try:
                    end_century = soup.find("origdate")["notafter"]
                except:
                    end_century = ""

        if end_century:
            end_century = date_to_century(end_century)
        print(end_century)


        #TODO - this needs to be fixed in data not in script
        origplace = ""
        try:
            origplace = soup.find("history").find("origplace").find("country")
            origplace = origplace.get_text()
        except:
            try:
                origplace = soup.find("history").find("origplace")
                origplace = origplace.get_text()
            except:
                origplace = ""
        print(origplace)

        country=""
        if origplace:
            country=origplace_to_country(origplace)
        print (country)

        material=""
        try:
            material=soup.find("supportdesc")["material"]
        except:
            material = ""
        print (material)

        script=""
        try:
            script=soup.find("handnote")["script"]
            if " " in script:
                script=script.partition(' ')[0]
            #TODO - this needs to be fixed in the data
            if script == "nastaliq":
                script="nasta_liq"

        except:
            script = ""
        print (script)

        mainlang=""
        try:
            mainlang=soup.find("textlang")["mainlang"]
        except:
            mainlang = ""
        print (mainlang)

        ruledlines = ""
        try:
            ruledlines = soup.find("layout")["ruledlines"]
            if " " in ruledlines:
                ruledlines=ruledlines.rpartition(" ")[-1]
            if "-" in ruledlines:
                ruledlines=ruledlines.rpartition("-")[-1]
        except:
            ruledlines = ""
        print(ruledlines)

        dimension_unit=""
        try:
            dimension_unit = soup.find("dimensions", {"type": "leaf"})["unit"]
        except:
            dimension_unit = ""
        print(dimension_unit)


        height = ""
        try:
            height = soup.find("dimensions", {"type": "leaf"}).find("height")
            height=height.get_text()
            if "-" in height:
                height = height.rpartition("-")[-1]
            height=float(height)
            if dimension_unit == "cm":
                height=height*10
        except:
            height = ""
        print(height)

        width = ""
        try:
            width = soup.find("dimensions", {"type": "leaf"}).find("width")
            width = width.get_text()
            if "-" in width:
                width = width.rpartition("-")[-1]
            width=float(width)
            if dimension_unit == "cm":
                width=width*10
        except:
            width = ""
        print(width)

        largest_size=""
        if height and width:
            largest_size=max(height, width)
        print (largest_size)

        deconote = ""
        try:
            deconote = soup.find("decodesc").find("deconote")
            deconote = deconote.get_text()
        except:
            deconote = ""

        decorated="N"
        if deconote:
            decorated="Y"
            #print ("Deconote:" + deconote)
        print(decorated)

        orientation=""
        if height and width:
            if height>width:
                orientation="P"
            else:
                orientation="L"
        print(orientation)

        lines=""
        if ruledlines:
            ruledlines=int(ruledlines)
            if ruledlines<11:
                lines="1_10"
            elif 11 <= ruledlines <= 20:
                lines="11_20"
            elif ruledlines > 20:
                lines="21_plus"
        print(lines)


        size=""
        if largest_size:
            #largest_size=int(largest_size)
            if largest_size <200:
                size="S"
            elif 200 <= largest_size <= 299:
                size="M"
            elif largest_size > 299:
                size="L"
        print (size)

        csvwriter.writerow(
            [msid, filename, repository, collection, idno, start_century, end_century,  origplace, country, material, script, mainlang, decorated,
             orientation, lines, size])

csvfile.close()

df = pd.read_csv("output.csv")

df.to_pickle("dataframe.pkl")