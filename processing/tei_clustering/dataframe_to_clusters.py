import csv
import argparse
import pandas as pd

pd.set_option('display.max_columns', None)
pd.set_option("max_rows", None)
pd.set_option('expand_frame_repr', False)
pd.set_option('max_colwidth', 20)
pd.options.display.float_format = '{:,.0f}'.format

# construct the argument parse and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-d", "--dataframefile", required=True, help="dataframe file")
ap.add_argument('-f','--cluster_fields', nargs='+', help='list of fields to cluster by', required=True)
args = vars(ap.parse_args())

dataframefile=args["dataframefile"]cluster_fields=args["cluster_fields"]
print (cluster_fields)

df = pd.read_pickle(dataframefile)

#grouped_df=df.groupby(["script", "mainlang", "decorated", "size", "lines"])

grouped_df=df.groupby(cluster_fields)

cluster_number=1

for key, item in grouped_df:

    cluster=grouped_df.get_group(key)

    if len(cluster.index) > 10:
        print (cluster, "\n\n")
        cluster_path=f"clusters/cluster_{cluster_number}.csv"
        print (cluster_path)
        cluster_number+=1
        cluster.to_csv(cluster_path)
