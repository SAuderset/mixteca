# Generating a print dictionary from lexical databases in spreadsheet format

The workflow described here is specific to my project, but with minor adaptions it should be applicable to comparable projects. I'm sure it could be improved in many ways, as it relies on a series of tools (instead of just using python, for example) and multiple 'manual' steps that could potentially be automated. But it works for me and is not terribly inefficient. 
I wrote this mainly to keep track of what I'm doing. I'm not giving any details here, but feel free to reach out if you want to know more. 

## Starting point:
The live version database of the database lives on Box in xlsx-format.This is because multiple people are working on it who live on different continents. It is an ongoing project and the database gains new entries quite frequently. 

## Part 1: 

1. download the database files and save relevant parts as csv 
1. read all of that into python to clean, order, etc. 
    1. a major issue is sorting; standard alphabetical order is not appropriate because of di- and tri-graphs and the tone diacritics
    1. we want to normalize unicode representation and get rid of extra white space (so it will look nice)
    1. clean up and write to csv


## Part 2: Import to LaTeX and make it look pretty

1. set up LaTex document (I used this [template](https://www.overleaf.com/latex/examples/dictionary-template/pdztbwjxrpmz) as the basis but adjusted it)
1. add a nice title page, don't forget copyright, credits, etc.
1. generate pdf and voilà!

Many thanks to Kevin Schaefer for the initial idea and to Tiago Tresoldi for finding a solution to my sorting problem!
