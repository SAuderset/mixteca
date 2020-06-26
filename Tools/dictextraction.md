# extract text from dictionaries

1. cut part of pdf with dictionary entries (text extraction will run faster, and ultimately we only need this part)
2. convert to tif (with Preview, command line also works but isn't faster)
3. run tesseract (command line) on the tif file to extract text (it does not work with pdf)
..* language options: spa or eng, depending on the translation language
..* if tone diacritics are use, plus yor (Yoruba)
4. inspect output and clean up with regex as far as possible (with Textmate)
5. read file into R to further clean and export to csv


