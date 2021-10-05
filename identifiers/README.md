# Fihrist Manuscript Identifiers

This folder contains a plain text file for each Fihrist member institution. 
Each contains 1000 manuscript IDs pre-allocated for their use when creating
new records for previously-uncatalogued manuscripts.

These are for use in the root `TEI` element of TEI records:
```
<TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="_____">
```

How to manage the use of identifiers within your instituion is up to you. 
For example, you could copy and paste all 1000 IDs into a spreadsheet which 
you keep in a shared drive, internal SharePoint system, or on Google Docs. You
could then allocate subsets to individual cataloguers, or just flag the ones
you use as you use them. As long as everyone cataloguing the same institution's 
collections has access to the same spreadsheet. __Do not keep spreadsheets 
here on GitHub because it does not automatically keep copies synchronized.__

If you find you are running out of your allocation, please 
[create a new issue](https://github.com/fihristorg/fihrist-mss/issues/new) 
asking for more. I have written a script which I will then run to 
top-up your text file back to 1000 new distinct IDs again. 

__Nobody should manually edit these text files.__ If you lose track of which IDs 
you have used so far, please also raise an issue.
