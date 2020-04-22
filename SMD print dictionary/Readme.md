# Generating a print dictionary from lexical databases in spreadsheet format

The workflow described here is specific to my project, but with minor adaptions it should be applicable to comparable projects. I'm sure it could be improved in many ways, as it relies on a series of tools (instead of just using python, for example) and multiple 'manual' steps that could potentially be automated. But it works for me and is not terribly inefficient. 
I wrote this mainly to keep track of what I'm doing. I'm not giving any details here, but feel free to reach out if you want to know more. 

## Starting point:
The live version database of the database lives on Box in xlsx-format.This is because multiple people are working on it who live on different continents. It is an ongoing project and the database gains new entries quite frequently. 

## Part 1: Clean, subset, and convert to csv

1. download the database files (in my case: [lexical entries](SMD-Base_de_datos_lexica.xlsx) and [verbs](SMD-Base_de_datos_verbal.xlsx))
1. create the sort order for the entries in a separate [csv-file](smd_sortorder.csv); this is especially important if you have diacritics and di-/trigraphs and/or do not want to sort according to the English alphabetical sorting convention
1. read all of that into R, clean, subset and write to csv.

## Part 2: Import to LaTeX and make it look pretty

1. set up LaTex document (I used this [template](https://www.overleaf.com/latex/examples/dictionary-template/pdztbwjxrpmz) as the basis but adjusted it)
1. add a nice title page, don't forget copyright, credits, etc.
1. generate pdf and voilà!
