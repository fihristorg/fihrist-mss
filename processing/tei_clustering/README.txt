This set of scripts was written for the CHRG-funded project "Investigating the origins of Islamicate manuscripts using computational methods" (2021-2022). The aim of the project was to see if sets of manuscripts which shared certain codicological features could be hypothesised to also share place/date of origin.

They were written to work with the Fihrist dataset, but should work (with some tweaking) with any TEI dataset using msDesc for manuscript description.

The primary functions of the scripts are to take a set of TEI records containing manuscript descriptions (msDesc) in the header and output:

- clusters of manuscripts sharing codicological features, including information on how to identify each manuscript in the dataset, information on the date/place of origin of each manuscript, and the codicological features used to cluster the manuscripts
- a linked open data representation of a subset of information from the TEI records
- charts which give statistical analyses of the dataset by place and by date


1. tei_to_csv_and_dataframe.py

The starting point is the generation of a csv file and a python pickle (dataframe) file containing selected and normalised data from the TEI dataset. This script takes the path to the TEI dataset (a directory containing the TEI files you want to analyse) as a parameter, e.g.:

tei_to_csv_and_dataframe.py -t ~/Projects/fihrist/collections/the\ university\ of\ manchester/

It outputs two files, which form the inputs of the other scripts:

output.csv
dataframe.pkl


2. csv_to_rdf.py

This script takes a csv file as input and generates a simple ref (Linked Open Data) representation of the data, mainly using the Bibframe ontology with some local additions. It takes the path to the csv file as input, e.g.:

python3 csv_to_rdf.py -c output.csv

It outputs one file, which contains the rdf:

outfile.rdf


3. dataframe_to_clusters.py

NB before running this script, create a directory called clusters in the same folder as it.

This script takes a python dataframe (.pkl) file as input and outputs clusters of manuscripts sharing specified codicological features. It takes the python dataframe file and a list of the features to cluster by as inputs (these features must be column headings in the input file), e.g.:

python3 dataframe_to_clusters.py -d dataframe.pkl -f material size lines mainlang decorated script

It outputs all clusters to screen, and clusters with over 10 manuscripts as csv files to the clusters directory:

clusters/cluster_1.csv
clusters/cluster_2.csv
etc.

4. dataframe_to_plot.py

This script takes a python dataframe (.pkl) file as input and outputs graphs showing statistical information by time or by place. You can choose whether to plot by time (century) or by place (country). You can also choose to view the statistics either by number of manuscripts with a particular feature, or percentage of manuscripts with a particular feature. The feature must be a column heading in the dataset

As input, it takes	-d - dataframe file (.pkl)
			-c - feature/column to plot by
			-q - type of query (t for time, p for place)
			-o - output type (p for percentage, v for values)

e.g.:
To plot language by place as a percentage:
dataframe_to_plot.py -d dataframe.pkl -c mainlang -q p -o  p

To plot language by time as a percentage:
dataframe_to_plot.py -d dataframe.pkl -c mainlang -q t -o  p

To plot script by place as a value:
dataframe_to_plot.py -d dataframe.pkl -c script -q p -o  v

To plot script by time as a value:
dataframe_to_plot.py -d dataframe.pkl -c script -q t -o  v