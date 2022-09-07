import argparse
import pandas as pd
import matplotlib.pyplot as plt

# construct the argument parse and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-d", "--dataframefile", required=True, help="dataframe file")
ap.add_argument("-c", "--plotcolumn", required=True, help="column to plot values")
ap.add_argument("-o", "--outputtype", required=True, help="output type - p for percentage, v for values")
ap.add_argument("-q", "--querytype", required=True, help="query type - p for place, t for time")

args = vars(ap.parse_args())

dataframefile=args["dataframefile"]
plotcolumn=args["plotcolumn"]
outputtype=args["outputtype"]
querytype=args["querytype"]

df = pd.read_pickle(dataframefile)
df.dropna(subset=[plotcolumn], inplace=True)


ylabel=""
yvalues=[]
ycolumn=""
if querytype=="t":
    df.dropna(subset=['start_century'], inplace=True)
    ylabel="Century"
    max_century=int(df.loc[(df['size'].notnull())].start_century.max())
    min_century=int(df.loc[(df['size'].notnull())].start_century.min())
    yvalues=range(min_century,max_century)
    ycolumn="start_century"

else:
    df.dropna(subset=['country'], inplace=True)
    ylabel="Country"
    yvalues=df['country'].unique()
    ycolumn="country"


plotcolumn_values=df[plotcolumn].unique()
print(plotcolumn_values)

data_percentages={}
data_values={}

for plotcolumn_value in plotcolumn_values:

    value_percentages=[]
    values=[]

    for n in yvalues:
        all_values=df.loc[df[ycolumn] == n].filename.count()

        value=df.loc[(df[plotcolumn] == plotcolumn_value) & (df[ycolumn] == n)].filename.count()
        values.append(value)

        value_percent = int((value / all_values) * 100)
        value_percentages.append(value_percent)

    #print(value_data)
    data_percentages[plotcolumn_value]=value_percentages
    data_values[plotcolumn_value]=values

plot_df=pd.DataFrame()
label=""

if outputtype=='v':

    plot_df=pd.DataFrame(data_values,
                     index=yvalues)
    label="Number of manuscripts"

else:
    plot_df = pd.DataFrame(data_percentages,
                           index=yvalues)
    label = "Percentage of manuscripts"

print(plot_df)

ax=plot_df.plot.barh(title='Manuscripts by '+plotcolumn)
ax.legend(loc='lower right')
ax.set_xlabel(label)
ax.set_ylabel(ylabel)

plt.show()
