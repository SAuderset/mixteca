# extract text from dictionaries

1. cut part of pdf with dictionary entries (text extraction will run faster, and ultimately we only need this part)
2. convert to tiff (either with Preview (fails on bigger files) or with https://pdf2tiff.com/de/)
3. run tesseract (command line) on the tiff file to extract text (it does not work with pdf)
..* language options: spa or eng, depending on the translation language
..* if tone diacritics are use, plus yor (Yoruba)
Example command: tesseract infile.tiff outfile -l spa+yor --dpi 150
4. inspect output and clean up with regex as far as possible (with Textmate)
5. read file into R to further clean and export to csv


